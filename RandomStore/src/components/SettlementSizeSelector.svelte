<script>
    import { selectedSettlement } from "../stores/SettlementSelectorStore"; 
</script>

<style>
    .SSelect {
        flex: 2;
    }
</style>

<div class="SSelect">
    <label for="settlementSelector">Select the size of settlement the store is in:</label>
    <select id="settlementSelector" class="SettlementSelector" bind:value={$selectedSettlement}>
        <option value="travelling_merchant">Peddlar</option>
        <option value="village">Village</option>
        <option value="town">Town</option>
        <option value="city">City</option>
    </select>
</div>

