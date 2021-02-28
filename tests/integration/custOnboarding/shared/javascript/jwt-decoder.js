function(token) {
    var base64Url = token.split('.')[1];
    var base64Str = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    var Base64 = Java.type('java.util.Base64');
    var decoded = Base64.getDecoder().decode(base64Str);
    var String = Java.type('java.lang.String');
    return new String(decoded);
}