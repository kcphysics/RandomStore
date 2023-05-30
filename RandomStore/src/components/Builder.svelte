<script>
  import ControlBox from './ControlBox.svelte';
  import ShopMetaData from './ShopMetaData.svelte';
  import ShopItemList from './ShopItemList.svelte';
</script>

<style>
    hr {
        width: 50%;
    }
</style>

<p>Use the tool below to create a randomized Store for a settlement in your campaign!</p>
<ControlBox />
<hr>
<ShopMetaData />
<hr>
<ShopItemList />
<hr>