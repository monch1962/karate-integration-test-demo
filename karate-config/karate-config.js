function fn() {
    var config = {
        baseUrl: 'http://localhost:8888',
        proxy: {
            uri: 'http://localhost:18500'
        }
    }
    karate.configure('proxy', config.proxy);
    karate.configure('readTimeout', 10000);
    karate.configure('connectTimeout', 10001);
    //var classPath = java.lang.System.getenv('CLASSPATH');
    return config;
}

