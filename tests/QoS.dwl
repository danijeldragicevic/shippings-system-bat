%dw 2.0 
import * from bat::BDD
import * from bat::Assertions

var context = bat::Mutable::HashMap()

/**
* Executes GET request against the API's /shippings resource.
*
* Takes the complete response and store it into the "context" HashMap, 
* so it can be used in the further tests assertions.
*
* Returns:
* - Object with test attributes.
*/
fun getShippings(): Object = (
    GET `$(config.url)/shippings` with { 
        allowUnsafeSSL: true
    } execute [
        context.set("response", $.response default "")
    ]
)

---
describe `Test Quality of Service policies` in [
    // Must return Bad Request, since API Quota Limit is 15 requests per minute.
    it must "reach quota limit" in [
        repeat(30) times [
            getShippings() 
        ] assert [
            context.get("response").status          mustEqual 429,
            context.get("response").statusText      mustEqual "Too Many Requests",
            context.get("response").mime            mustEqual "application/json",
            context.get("response").body.error      mustEqual "Quota has been exceeded"
        ]
    ]
]
