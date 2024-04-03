%dw 2.0 
import * from bat::BDD
import * from bat::Assertions
import * from dw::core::Arrays
import * from dw::core::Strings

var context = bat::Mutable::HashMap()

/**
* Executes GET request against the API's /shippings resource.
*
* Takes the "id" of the first record returned in the response body
* and store it into the "context" HashMap as "shippingId", 
* so it can be used in the further tests assertions.
* 
* If there are no shippings in returned payload, "shippingId" will be set to zero.
*
* Returns:
* - Object with test attributes.
*/
fun getShippings(): Object = (
    GET `$(config.url)/shippings` with {
        allowUnsafeSSL: true
    } execute [
        context.set("shippingId", $.response.body[0].id default 0)
    ]
)

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

/*
* Get shipping by requested id.
* 
* Input arguments:
* - id (Number): Id number of requested shipping.
* 
* Returns:
* - Object with test arguments.
* */
fun getShippingById(id: Number): Object = (
    GET `$(config.url)/shippings/$(id)` with {
        allowUnsafeSSL: true
    }
)

/**
* Executes PUT request against the API's /shippings/{id} resource.
*
* Takes the "shippingId" from returned response 
* and store it into the "context" HashMap as "shippingId", 
* so it can be used in the further tests assertions.
*
* Returns:
* - Object with test attributes.
*/
fun updateShippingById(id: Number): Object = (
    PUT `$(config.url)/shippings/$(id)` with {
        allowUnsafeSSL: true,
        body: {
                "shipTo": {
                  "userId": 1,
                  "name": "George Constanza",
                  "email": "george.constanza@comedyshow.com",
                  "phone": "(212) 555-9999"
                },
                "billingAddress": {
                  "street": "1344 Queens Blvd.",
                  "city": "New York City",
                  "state": "New York State",
                  "postalCode": "10024",
                  "country": "United States"
                },
                "shippingAddress": {
                  "street": "1344 Queens Blvd.",
                  "city": "New York City",
                  "state": "New York State",
                  "postalCode": "10024",
                  "country": "United States"
                }
              }
    }
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
describe `Test /shippings/{id} resource` in [
    // If shipping exists, must return shipping with requested id, otherwise returns Not Found
    it must "get shipping by id" in [
        getShippings(),
        if (context.get("shippingId") != 0) (
            getShippingById(context.get("shippingId")) assert [
                $.response.status                       mustEqual 200,
                $.response.statusText                   mustEqual "OK",
                $.response.mime                         mustEqual "application/json",
                (typeOf($.response.body) as String)     mustEqual "Object",
                $.response.body.id                      mustEqual context.get("shippingId")
            ]
        ) else (
            getShippingById(context.get("shippingId")) assert [
                $.response.status                       mustEqual 404,
                $.response.statusText                   mustEqual "Not Found",
                $.response.mime                         mustEqual "application/json",
                (typeOf($.response.body) as String)     mustEqual "Object",
                ($.response.body.message)               mustEqual "Shipping was not found!",
                isEmpty($.response.body.correlationId)  mustEqual false   
            ] 
        )
    ],
    
    // Should create new shipping and updates it's values, otherwise returns Not Found
    it should "update shipping by id" in [
        createShipping(),
        if (context.get("shippingId") != 0) (
            updateShippingById(context.get("shippingId")) assert [
                $.response.status                       mustEqual 200,
                $.response.statusText                   mustEqual "OK",
                $.response.mime                         mustEqual "application/json",
                (typeOf($.response.body) as String)     mustEqual "Object",
                $.response.body.status                  mustEqual "Shipping successfully updated",
                $.response.body.shippingId              mustEqual context.get("shippingId")
            ] execute [
                deleteShippingById(context.get("shippingId"))
            ]
        ) else (
            updateShippingById(context.get("shippingId")) assert [
                $.response.status                       mustEqual 404,
                $.response.statusText                   mustEqual "Not Found",
                $.response.mime                         mustEqual "application/json",
                (typeOf($.response.body) as String)     mustEqual "Object",
                ($.response.body.message)               mustEqual "Shipping was not found!",
                isEmpty($.response.body.correlationId)  mustEqual false   
            ] 
        )
    ],
    
    // Should create new shipping and deletes it, otherwise returns Not Found
    it should "delete shipping by id" in [
        createShipping(),
        if (context.get("shippingId") != 0) (
            deleteShippingById(context.get("shippingId")) assert [
                $.response.status                       mustEqual 200,
                $.response.statusText                   mustEqual "OK",
                $.response.mime                         mustEqual "application/json",
                (typeOf($.response.body) as String)     mustEqual "Object",
                $.response.body.status                  mustEqual "Shipping successfully deleted",
                $.response.body.shippingId              mustEqual context.get("shippingId")
            ]
        ) else (
            deleteShippingById(context.get("shippingId")) assert [
                $.response.status                       mustEqual 404,
                $.response.statusText                   mustEqual "Not Found",
                $.response.mime                         mustEqual "application/json",
                (typeOf($.response.body) as String)     mustEqual "Object",
                ($.response.body.message)               mustEqual "Shipping was not found!",
                isEmpty($.response.body.correlationId)  mustEqual false   
            ] 
        )
    ]
]
