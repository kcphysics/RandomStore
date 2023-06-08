<script>
    export let storeid
    import { onMount } from "svelte";
    import { getShop } from "../lib/shop_api";
    import ShopItemList from "./ShopItemList.svelte";
    import { shop } from '../stores/SettlementSelectorStore';
    import ErrorCard from "./ErrorCard.svelte";

    let error_message = "";

    onMount(async () => {
        console.log(`Mounting data for StoreID: ${storeid}`)
        try {
            var shopData = await getShop(storeid);
            if (shopData.storeid == "" || shopData.hasOwnProperty("message") || shopData.hasOwnProperty("error")) {
                error_message = `Could not get ${storeid} from the server, there may be an error or the store may not exist`
                return
            }
            shop.set(shopData);
        } catch(error) {
            console.log(String(error))
            error_message = `Could not get ${storeid} from the server, there may be an error or the store may not exist`
        }
    })
</script>

<style>
    hr {
        width: 50%;
    }

    .tagLine {
        font-size: small;
    }
</style>

<p class="tagLine">If you want to generate one for yourself, click <a href="/">here</a></p>
<hr>
{#if error_message != ""}
    <ErrorCard {error_message} />
{:else}
    <ShopItemList />
{/if}
<hr>