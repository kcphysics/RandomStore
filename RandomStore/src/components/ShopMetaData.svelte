<script>
    import { scarcityEvents, shop } from '../stores/SettlementSelectorStore';
</script>

<style>
    .ShopMetaData {
        text-align: left;
    }
    details > summary {
        font-size: larger;
        font-weight: bold;
    }
</style>

<details>
    <summary>Details of the Shop Generation</summary>
    <div class="ShopMetaData">
        <p><strong>Shop Name: </strong> {$shop.name}</p>
        <p><strong>Settlement Size: </strong> {$shop.config.settlementType}</p>
        <p><strong>Number of Scarcity Events: </strong> {$shop.config.numberScarcityEvents}</p>
        <p><strong>Scarce Tags:</strong></p>
        <ul>
            {#each $shop.config.ScarceTags as tag}
            <li>{tag}</li>
            {/each}
        </ul>
        <p><strong>Number of Surplus Events: </strong> {$shop.config.numberSurplusEvents}</p>
        <p><strong>Surplus Tags:</strong></p>
        <ul>
            {#each $shop.config.SurplusTags as tag}
            <li>{tag}</li>
            {/each}
        </ul>        
    </div>
</details>
