import { subscribe } from "svelte/internal";
import { writable, get } from "svelte/store";


export const selectedSettlement = writable("town")
export const scarcityEvents = writable(0)
export const surplusEvents = writable(0)
export const showOutOfStock = writable(false)
export const isViewingShop = writable(false)
export const shop = writable( {
    "name": "No Shop Generated",
    "config": {
        "settlementType": "None",
        "numberScarcityEvents": 0,
        "numberSurplusEvents": 0,
        "ScarceTags": [],
        "SurplusTags": []
    },
    "items": []
})


