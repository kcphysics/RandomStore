<script>
    import { scarcityEvents, surplusEvents } from "../stores/SettlementSelectorStore";
    import Icon from 'svelte-awesome'
    import infoCircle from "svelte-awesome/icons/infoCircle"
</script>

<style>
    .tooltip {
        position: relative;
        display: inline-block;
        border-bottom: 1px dotted black;
    }

    .tooltip .tooltiptext {
        visibility: hidden;
        width: 20rem;
        background-color: black;
        color: white;
        text-align: center;
        padding: 5px;
        border-radius: 6px;
        position: absolute;
        z-index: 1;
        bottom: 100%;
        left: 50%;
        margin-left: -10rem;
    }

    .tooltip:hover .tooltiptext {
        visibility: visible;
    }

    .ESelect {
        flex: 2;
        justify-self: center;
    }
</style>

<div class="ESelect">
    <label class="tooltip" for="scarcityEvent">
        Number of Scarcity Events: 
        <Icon data={infoCircle} />
        <span class="tooltiptext">These will make good associated with the event more expensive and harder to find</span>
    </label>
    <input id="scarcityEvent" type=range bind:value={$scarcityEvents} min=0 max=10 />
    <p>Current Scarcity: {$scarcityEvents}</p>
</div>
<div class="ESelect">
    <label class="tooltip" for="surplusEvent">
        Number of Surplus Events:
        <Icon data={infoCircle} />
        <span class="tooltiptext">These will make good associated with the event less expensive and easier to find</span>
    </label>
    <input id="surplusEvent" type=range bind:value={$surplusEvents} min=0 max=10 />
    <p>Current Scarcity: {$surplusEvents}</p>
</div>
