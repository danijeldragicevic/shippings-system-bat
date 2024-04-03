# Shippings System BAT

Welcome to the Shippings System Blackbox Automated Testing (BAT) Suite! <br>
Those tests are designed to fire HTTP requests against running Mule application, and do various assertions against response(s) returned.

# Demo Disclaimer
This test suite is a demo created for educational purposes and is associated with a blog post. It is not representing a fully functional or production-ready system. 
Please refer to the [blog post](https://example.com) for insights into the concepts and use cases demonstrated.

# Technology
- BAT CLI wrapper 1.1.56;
- DataWeave 2.0, with BDD and Assertions libs;

# How to run the tests
## 1. Install BAT CLI on your localhost
Here is the instruction how to install BAT CLI on our local machine: [Installing BAT](https://docs.mulesoft.com/api-functional-monitoring/bat-install-task). <br>

For MacOS and Linux systems, all we have to do is to run this command:
```
curl -o- 'https://s3.amazonaws.com/bat-wrapper/install.sh' | bash
```

Verify that BAT is successfully installed on our machine:
```
bat -version
BAT Version: 1.1.56
```

## 2. Run tests
- Checkout and run this Mule applicaiton: [Shippings System App](https://github.com/danijeldragicevic/shippings-system-app/tree/main);
- Once we have our Mule application up and running, we can checkout repository of this test suite;
- Navigate to the project's root directory and run following command: "bat --config=local-env";

This way we will instruct BAT to use endpoint defined in the "/config/local-env.dwl" file. Output should look similar to this:
```
~/IdeaProjects/shippings-system-bat/ [main] bat --config=local-env                     
BAT Version: 1.1.56
#  File: tests/Shippings.dwl
*** Setting script timeout (3599997 ms) ***
  
  /shippings
      
      get all shippings
        ✓ GET http://localhost:8081/api/shippings (346.1ms)
            Stored new value for qparamFullName
          ✓ 200 must equal 200
          ✓ "OK" must equal "OK"
          ✓ "application/json" must equal "application/json"
          ✓ "Array" must equal "Array"
      
      get shippings where name equals
        ✓ GET http://localhost:8081/api/shippings?match=equals&name=Jerry%20Seinfield (203.24ms)
          ✓ 200 must equal 200
          ✓ "OK" must equal "OK"
          ✓ "application/json" must equal "application/json"
          ✓ "Array" must equal "Array"
          ✓ every value in ["Jerry Seinfield", "Jerry Seinfield", "Jerry Seinfield"] must equal "Jerry Seinfield"
      
      get shippings where name like
        ✓ GET http://localhost:8081/api/shippings?match=like&name=Jerry (204.27ms)
            Stored new value for qparamFirstName
          ✓ 200 must equal 200
          ✓ "OK" must equal "OK"
          ✓ "application/json" must equal "application/json"
          ✓ "Array" must equal "Array"
          ✓ every value in ["Jerry Seinfield", "Jerry Seinfield", "Jerry Somersby", "Jerry Seinfield"] must match Regex /Jerry/
      
      create new shipping
{}
        ✓ POST http://localhost:8081/api/shippings (211.21ms)
            Stored new value for shippingId
          ✓ 201 must equal 201
          ✓ "Created" must equal "Created"
          ✓ "application/json" must equal "application/json"
          ✓ "Object" must equal "Object"
          ✓ "Shipping successfully created" must equal "Shipping successfully created"
          ✓ "95" must equal "95"
          ✓ DELETE http://localhost:8081/api/shippings/95 (410.74ms)
          ✓ DELETE http://localhost:8081/api/shippings/95 (410.74ms)
#  File: tests/ShippingsById.dwl
*** Setting script timeout (3594349 ms) ***
  
  /shippings/{id}
      
      get shipping by id
        ✓ GET http://localhost:8081/api/shippings (203.92ms)
            Stored new value for shippingId
        ✓ GET http://localhost:8081/api/shippings/1 (199.92ms)
          ✓ 200 must equal 200
          ✓ "OK" must equal "OK"
          ✓ "application/json" must equal "application/json"
          ✓ "Object" must equal "Object"
          ✓ 1 must equal 1
      
      update shipping by id
{}
        ✓ POST http://localhost:8081/api/shippings (203.53ms)
            Stored new value for shippingId
{}
        ✓ PUT http://localhost:8081/api/shippings/96 (403.43ms)
          ✓ 200 must equal 200
          ✓ "OK" must equal "OK"
          ✓ "application/json" must equal "application/json"
          ✓ "Object" must equal "Object"
          ✓ "Shipping successfully updated" must equal "Shipping successfully updated"
          ✓ "96" must equal "96"
          ✓ DELETE http://localhost:8081/api/shippings/96 (401.86ms)
          ✓ DELETE http://localhost:8081/api/shippings/96 (401.86ms)
      
      delete shipping by id
{}
        ✓ POST http://localhost:8081/api/shippings (204.18ms)
            Stored new value for shippingId
        ✓ DELETE http://localhost:8081/api/shippings/97 (399.18ms)
          ✓ 200 must equal 200
          ✓ "OK" must equal "OK"
          ✓ "application/json" must equal "application/json"
          ✓ "Object" must equal "Object"
          ✓ "Shipping successfully deleted" must equal "Shipping successfully deleted"
          ✓ "97" must equal "97"
#  Reporter: bat/Reporters/HTML.dwl >> reports/Report.html
#  Reporter: reporter/ReportCreator.dwl >> reports/Report.json
#  Reporter: bat/Reporters/Email.dwl >> <nowhere>
Reporter disabled: false - false
WARNING: Email reporter only works when the test is executed in Anypoint Platform. - ""
```

This test suite also uses Github Actions CI/CD, where it is instructed to run the tests on a scheduled basis and/or with each new commit against the "main" branch.
CI/CD runs tests against Shipping System Appliction deployed on Anypoint Platform's Runtime Manager (CH1).

Details about CI/CD configurations can be seen in ".github/workflows/build.yml" file.

Feel free to explore the test suite and use the provided examples to understand how to interact with each endpoint. If you have any questions or issues, please refer to the API documentation or contact the application maintainers.

# Licence
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
