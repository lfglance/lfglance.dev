exports.handler = async (event) => {
    const request = event.Records[0].cf.request;
    request.headers['host'] = [{
        key: 'Host',
        value: 'your-bun-function.up.railway.app'
    }];
    console.log(`Serving request for ${request.clientIp}`);
    return request
};