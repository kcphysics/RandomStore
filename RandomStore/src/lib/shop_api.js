export async function getShop(storeid) {
    var url = `https://api.randomstore.scselvy.com/getStore?storeid=${storeid}`;
    var resp = await fetch(url);
    var shopData = await resp.json();
    return shopData;
}

export async function saveShop(shop) {
    var url = `https://api.randomstore.scselvy.com/saveStore`
    var body = JSON.stringify(shop)
    try{
        var resp = await fetch(url, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(shop)
        })
        let response_json = await resp.json()
        console.log(response_json)
        return response_json;
    } catch (error) {
        console.log(error)
        return {
            error: error
        }
    }
}