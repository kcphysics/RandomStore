<script>
    export let storeid
    import { onMount } from "svelte";
    import { getShop } from "../lib/shop_api";
    import ShopItemList from "./ShopItemList.svelte";
    import { shop, showOutOfStock } from '../stores/SettlementSelectorStore';

    onMount(async () => {
        console.log(`Mounting data for StoreID: ${storeid}`)
        var shopData = await getShop(storeid);
        shop.set(shopData);
    })
</script>

<style>
    hr {
        width: 50%;
    }
</style>

<p>Welcome to {$shop.name}</p>
<hr>
<ShopItemList />
<hr>