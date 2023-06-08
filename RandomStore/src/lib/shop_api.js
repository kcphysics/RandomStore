

export async function getShop(storeid) {
    var ahead = await calculate_auth_header(storeid)
    var url = `${import.meta.env.VITE_API_ENDPOINT}/getStore?storeid=${storeid}`;
    var options = {
        method: "GET",
        headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${ahead}`
        }
    }
    console.log(`Attempting to fetch store ${storeid} from ${url}`)
    var resp = await fetch(url, options);
    var shopData = await resp.json();
    return shopData;
}

export async function saveShop(shop) {
    var storeid = shop.storeid
    var ahead = await calculate_auth_header(storeid)
    var url = `${import.meta.env.VITE_API_ENDPOINT}/saveStore`
    var body = JSON.stringify(shop)
    try{
        var resp = await fetch(url, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${ahead}`
            },
            body: JSON.stringify(shop)
        })
        try {
            let response_json = await resp.json()
            return response_json;
        } catch(error) {
            return {
                error: "Unable to parse response from server, could not save"
            }
        }
    } catch (error) {
        return {
            error: "Unexpeced error from server, could not save"
        }
    }
}

async function calculate_auth_header(storeid) {
    let astring=`rstore|==${storeid}==|rstore`
    const encoder = new TextEncoder()
    const data = encoder.encode(astring)
    const hashBuf = await crypto.subtle.digest("SHA-256", data)
    const hashArr = Array.from(new Uint8Array(hashBuf))
    const hash = hashArr.map((b) => b.toString(16).padStart(2, "0")).join("")
    return hash

}