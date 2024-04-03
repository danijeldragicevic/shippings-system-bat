%dw 2.0
output application/json

---
/*
* Takes the output of the executed tests 
* and creates custom report in /reports/Report.json file.
* */
{
    suiteName: payload.name,
    testedPaths: payload.result map ((res) -> {
        path: res.name,
        results: res.result map ((item) -> {
            test: item.name,
            pass: item.pass,
            requests: (item.result..name) filter ((name) -> name contains "http")
        })
    })
}
