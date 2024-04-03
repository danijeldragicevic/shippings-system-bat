%dw 2.0 
import * from bat::BDD
import * from bat::Assertions
import * from dw::core::Arrays
import * from dw::core::Strings

//TODO Why is Mutable here?
var context = bat::Mutable::HashMap()

fun getShippings() = (
    GET `$(config.url)/shippings` with {} execute [
        context.set('qparamName', $.response.body[0].shipTo.name)
    ]
)

fun getShippingsByName(qname: String, qmatch: String ) = do {
    var name = replaceAll(qname, " ", "%20")
    ---
   GET `$(config.url)/shippings?name=$(name)&match=$(qmatch)` with {}
}

---
describe `/shippings` in [
    it should "get all shippings" in [
        getShippings() assert [
            $.response.status                   mustEqual 200,
            $.response.mime                     mustEqual "application/json",
            (typeOf($.response.body) as String) mustEqual "Array"
        ] 
    ],

    it must "get all shippings, where name equals" in [
        getShippingsByName(context.get('qparamName'), "equals") assert [
            $.response.status                   mustEqual 200,
            $.response.mime                     mustEqual "application/json",
            (typeOf($.response.body) as String) mustEqual "Array",
            every ($.response.body.shipTo.name) mustMatch context.get('qparamName')
        ]
    ],

    it must "get all shippings, where name like" in [
        getShippingsByName(context.get('qparamName'), "like") assert [
            $.response.status                   mustEqual 200,
            $.response.mime                     mustEqual "application/json",
            (typeOf($.response.body) as String) mustEqual "Array",
            every ($.response.body.shipTo.name) mustMatch context.get('qparamName')
        ] execute [
            log($.response.body),
            log($.response.mime)
        ]
    ]
]
