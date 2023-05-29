<script>
  import Footer from './components/Footer.svelte';
  import Header from './components/Header.svelte';
  import Builder from './components/Builder.svelte';
  import ShopViewer from './components/ShopViewer.svelte';
  import {isViewingShop} from  './stores/SettlementSelectorStore';
  const urlParams = new URLSearchParams(window.location.search)
  isViewingShop.set(urlParams.has('storeid'))
  const storeid = urlParams.get('storeid')
</script>

<Header />
<main>
  {#if $isViewingShop}
  <ShopViewer storeid={storeid} />
  {:else}
  <Builder />
  {/if}  
</main>
<Footer />

<style>
  main {
    padding-left: 2rem;
    padding-right: 2rem;
  }
</style>
