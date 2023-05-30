<script>
    import items from "../data/adventure_gear.json";
    import generateStoreName from "../lib/name_generator";
    import {get} from 'svelte/store'
    import SettlementSizeSelector from "./SettlementSizeSelector.svelte";
    import EventSelector from "./EventSelector.svelte";
    import { selectedSettlement, surplusEvents, scarcityEvents, shop } from '../stores/SettlementSelectorStore';

    let settlementMap = new Map([
        ["town", 0],
        ["village", -0.1],
        ["city", 0.1]
    ])

    function getAvailableTags() {
        let allTags = new Set();
        items.forEach((item) => {
            allTags = new Set([...allTags, ...item.tags])
        });
        return [...allTags]
    }

    function getRandomInt(max) {
        return Math.floor(Math.random() * max);
    }

    function createEvents(num_scarcity_events, tags) {
        let scarcity_tags = []
        for (let i=0; i < num_scarcity_events; i++) {
            let ndx = getRandomInt(tags.length);
            let val = tags[ndx];
            tags.splice(ndx, 1)
            scarcity_tags.push(val)
        }
        return scarcity_tags
    }

    function calculateCoefficients(settlementType, scarcityTags, surplusTags) {
        let settlement_coefficient = settlementMap.get(settlementType)
        let coefficientMap = new Map();
        scarcityTags.forEach((tag) => {
            coefficientMap.set(tag, settlement_coefficient - 0.1)
        })
        surplusTags.forEach((tag) => {
            coefficientMap.set(tag, settlement_coefficient + 0.1)
        })
        return coefficientMap
    }

    function getStockedQuantity(item) {
        let weight_c = 0
        if (item.weight <= 1) {
            weight_c = 0
        } else if (item.weight <= 5) {
            weight_c = 0.25
        } else {
            weight_c = 0.4
        }
        let cost_c = 0
        if (item.base_price <= 1) {
            cost_c = 0
        } else if (item.weight <= 10) {
            cost_c = 0.1
        } else if (item.weight <=50 ) {
            cost_c = 0.25
        } else {
            cost_c = 0.4
        }
        let avail = item.base_availability - cost_c - weight_c
        return Math.floor(item.base_stock * avail)
    }

    function getPrice(item, total_coefficient) {
        return Math.floor(((1 + total_coefficient) * item.base_price) + 1)
    }

    function updateItem(item, coefficientMap) {
        let total_coefficient = 0
        item.tags.forEach((tag) => {
            let val = coefficientMap.get(tag)
            if (val === undefined){
                return
            }
            total_coefficient += val
        })
        let base_chance = 0.8;
        let chance = base_chance + total_coefficient
        let in_stock = isStocked(chance)
        if (!in_stock) {
            item.stocked_quantity = 0
            item.price = 0
        } else {
            item.stocked_quantity = getStockedQuantity(item)
            item.price = getPrice(item, total_coefficient)
        }
    }

    function updateAllItems(items, coefficientMap) {
        items.forEach((item) => {
            updateItem(item, coefficientMap)
        })
    }

    function isStocked(chance) {
        return Math.random() < chance
    }


    function generateShop() {
        let settlementType = get(selectedSettlement);
        let numberScarcityEvents =  get(scarcityEvents);
        let numberSurplusEvents = get(surplusEvents)
        let tags = getAvailableTags();
        let scarcity_events = createEvents(numberScarcityEvents, tags)
        let surplus_events = createEvents(numberSurplusEvents, tags)
        let coeffientMap = calculateCoefficients(settlementType, scarcity_events, surplus_events)
        let newItems = [...items];
        updateAllItems(newItems, coeffientMap)
        let storeid = crypto.randomUUID()
        let storeName = generateStoreName()
        let newShop = {
            "storeid": storeid,
            "name": storeName,
            "config": {
                "settlementType": settlementType,
                "numberScarcityEvents": numberScarcityEvents,
                "numberSurplusEvents": numberSurplusEvents,
                "ScarceTags": scarcity_events,
                "SurplusTags": surplus_events
            },
            "items": newItems
        }
        shop.set(newShop);
    }
</script>

<style>
    .ControlBox {
        display: flex;
        flex-direction: row;
    }
    .ControlSubmit {
        display: flex;
        justify-content: center;
        align-items: center;
    }
</style>

<div class="ControlBox">
    <SettlementSizeSelector />
    <EventSelector />
</div>

<div class="ControlSubmit">
    <button on:click={generateShop} id="generateShop">Generate</button>
</div>