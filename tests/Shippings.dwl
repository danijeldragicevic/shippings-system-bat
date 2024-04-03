%dw 2.0 
import * from bat::BDD
import * from bat::Assertions
import * from dw::core::Arrays
import * from dw::core::Strings

var context = bat::Mutable::HashMap()

/**
* Executes GET request against the API's /shippings resource.
*
* Takes the "shipTo.name" of the first record returned in the response body
* and store it into the "context" HashMap as "qparamFullName", 
* so it can be used in the further tests assertions.
*
* Returns:
* - Object with test attributes.
*/
fun getShippings(): Object = (
    GET `$(config.url)/shippings` with {
        allowUnsafeSSL: true
    } execute [
        context.set("qparamFullName", $.response.body[0].shipTo.name default "")
    ]
)

/**
* Executes GET request against the API's /shippings resource,
* including the "match=equals" and "name" query parameters.
* 
* Input arguments:
* - qparamFullName (String): value for the "name" query parameter (i.e. Jerry Seinfield).
*
* Returns:
* - Object with test attributes.
*/
fun getShippings_WhereNameEquals(qparamFullName: String): Object = do {
    var name = replaceAll(qparamFullName, " ", "%20")
    ---
    GET `$(config.url)/shippings?match=equals&name=$(name)` with {
        allowUnsafeSSL: true
    }
}

/**
* Executes GET request against the API's /shippings resource,
* including the "match=like" and "name" query parameters.
*
* Also stores "qparamFirstName" into the "context" HashMap, 
* so it can be used in the further tests assertions.
* 
* Input arguments:
* - qparamFullName (String): value for the "name" query parameter (i.e. Jerry Seinfield).
*
* Returns:
* - Object with test attributes.
*/
fun getShippings_WhereNameLike(qparamFullName: String): Object = do {
    var qparamFirstName = (qparamFullName splitBy(" "))[0] default "" // <-- takes only first part of the "qparamFullName" (i.e. Jerry)
    ---
    GET `$(config.url)/shippings?match=like&name=$(qparamFirstName)` with {
        allowUnsafeSSL: true
    } execute [
        context.set("qparamFirstName", qparamFirstName)
    ]
}

/**
* Executes POST request against the API's /shippings resource.
*
* Takes the "shippingId" from returned response 
* and store it into the "context" HashMap as "shippingId", 
* so it can be used in the further tests assertions.
*
* Returns:
* - Object with test attributes.
*/
fun createShipping(): Object = (
    POST `$(config.url)/shippings` with {
        allowUnsafeSSL: true,
        body: {
                "shipTo": {
                  "userId": 1,
                  "name": "Jerry Seinfield",
                  "email": "jerry.seinfield@comedyshow.com",
                  "phone": "(212) 555-1234"
                },
                "billingAddress": {
                  "street": "129 West 81st Street",
                  "city": "New York City",
                  "state": "New York State",
                  "postalCode": "10024",
                  "country": "United States"
                },
                "shippingAddress": {
                  "street": "129 West 81st Street",
                  "city": "New York City",
                  "state": "New York State",
                  "postalCode": "10024",
                  "country": "United States"
                }
              }
    } execute [
        context.set("shippingId", $.response.body.shippingId default 0)
    ]
)

/**
* Executes DELETE request against the API's /shippings/{id} resource.
*
* Input arguments:
* - shippingId (Number): id of the shipping that have to be deleted.
*
* Returns:
* - Object with test attributes.
*/
fun deleteShippingById(shippingId: Number): Object = (
    DELETE `$(config.url)/shippings/$(shippingId)` with {
        allowUnsafeSSL: true
    }
)

---
describe `Test /shippings resource` in [
    // Must return all shippings if they exists, otherwise return the empty array.
    it must "get all shippings" in [
        getShippings() assert [
            $.response.status                       mustEqual 200,
            $.response.statusText                   mustEqual "OK",
            $.response.mime                         mustEqual "application/json",
            (typeOf($.response.body) as String)     mustEqual "Array"
        ] 
    ],
    
    // If shippings exists, must return only those where requested name is fully equal to the passed query parameter.
    it must "get shippings where name equals" in [
        getShippings_WhereNameEquals(context.get('qparamFullName')) assert [
            $.response.status                       mustEqual 200,
            $.response.statusText                   mustEqual "OK",
            $.response.mime                         mustEqual "application/json",
            (typeOf($.response.body) as String)     mustEqual "Array",
            every($.response.body.shipTo.name)      mustEqual context.get("qparamFullName")
        ]
    ],

    // If shippings exists, must return only those where requested name is like the passed query parameter.
    it must "get shippings where name like" in [
        getShippings_WhereNameLike(context.get('qparamFullName')) assert [
            $.response.status                       mustEqual 200,
            $.response.statusText                   mustEqual "OK",
            $.response.mime                         mustEqual "application/json",
            (typeOf($.response.body) as String)     mustEqual "Array",
            every($.response.body.shipTo.name)      mustMatch (context.get("qparamFirstName") as Regex)
        ]
    ],
    
    // Should create new shipping and delete it afterwards.
    it should "create new shipping" in [
        createShipping() assert [
            $.response.status                       mustEqual 201,
            $.response.statusText                   mustEqual "Created",
            $.response.mime                         mustEqual "application/json",
            (typeOf($.response.body) as String)     mustEqual "Object",
            $.response.body.status                  mustEqual "Shipping successfully created",
            $.response.body.shippingId              mustEqual context.get("shippingId")
        ] execute [
            if (context.get("shippingId") != 0) (
                deleteShippingById(context.get("shippingId"))
            ) else (
                log("Shipping was not successfully created. There is nothing to delete...")
            )
        ] 
    ]    
]
