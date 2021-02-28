function() {
    while (true) {
        var dupCheck = karate.call('classpath:shared/customer-duplicate-check.feature')
        var isDuplicate = dupCheck.isDuplicate
        var status = dupCheck.status
        if (isDuplicate == false) {
            return {"phoneNumber": dupCheck.phone, "email": dupCheck.email }
        } else if(status != 200) {
            karate.log('Server Error! ' + status);
            karate.abort();
        }
    }
}