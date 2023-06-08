<script>
    import { Icon } from "svelte-awesome";
    import save from "svelte-awesome/icons/save";
    import plus from "svelte-awesome/icons/plus";
    import clipboard from "svelte-awesome/icons/clipboard";
    import checkCircle from "svelte-awesome/icons/checkCircle";
    import pencil from "svelte-awesome/icons/pencil";
    import {get} from 'svelte/store';
    import {saveShop} from "../lib/shop_api";
    import ShopItem from "./ShopItem.svelte";
    import { shop, showOutOfStock, isViewingShop } from '../stores/SettlementSelectorStore';
    import ErrorCard from "./ErrorCard.svelte";

    let confirmSaveDlg;
    let addNewItemDlg;
    let urlDisplayDlg;
    let changeStoreNameDlg;
    let newStoreName
    let newName;
    let newWeight;
    let newPrice;
    let newStock;
    let newDescription;
    let ShopID;
    let ShopURL;
    let completeIcon = clipboard;
    let error_message = "";

    function showSaveDialog() {
        confirmSaveDlg.showModal()
    }
    function cancelSave() {
        confirmSaveDlg.close()
    }
    async function saveStore() {
        let shopCopy = get(shop)
        let resp = await saveShop(shopCopy)
        if (resp.hasOwnProperty("error") || resp.hasOwnProperty("message")){
            error_message = resp.error
            return
        } else {
            console.log(resp)
            ShopID = resp.ShopID
            ShopURL = resp.ShopURL
        }
        confirmSaveDlg.close()
        urlDisplayDlg.showModal()
        completeIcon = clipboard
    }

    function closeUrlDlg() {
        urlDisplayDlg.close()
    }

    function copyUrlToClipboard() {
        navigator.clipboard.writeText(ShopURL)
        completeIcon = checkCircle
    }

    function updateItem(event) {
        var itemName = event.detail.item.name
        var newItem = event.detail.item
        var oshop = get(shop)
        var existing_ndx = oshop.items.findIndex(item => item.name === itemName)
        oshop.items[existing_ndx] = Object.assign(oshop.items[existing_ndx], newItem)
        shop.set(oshop)
    }

    function deleteItem(event) {
        var itemName = event.detail.name
        var oshop = get(shop)
        var existing_ndx = oshop.items.findIndex(item => item.name === itemName)
        oshop.items.splice(existing_ndx, 1)
        shop.set(oshop)
    }

    function addNewItem() {
        var oshop = get(shop)
        oshop.items.push({
            name: newName,
            price: newPrice,
            stocked_quantity: newStock,
            weight: newWeight,
            description: newDescription
        })
        oshop.items.sort((a, b) => {
            var name1 = a.name.toUpperCase()
            var name2 = b.name.toUpperCase()
            return (name1 < name2) ? -1: (name1 > name2) ? 1: 0
        })
        shop.set(oshop)
        addNewItemDlg.close()
    }

    function cancelAddNew() {
        addNewItemDlg.close()
    }

    function showAddNewDialog() {
        addNewItemDlg.showModal()
    }

    function showNewStoreNameDialog() {
        changeStoreNameDlg.showModal()
    }
    
    function cancelNewStoreName() {
        changeStoreNameDlg.close()
    }

    function saveNewStoreName() {
        var oshop = get(shop)
        oshop.name = newStoreName
        shop.set(oshop)
        changeStoreNameDlg.close()
    }
</script>

<style>
    .ShopList {
        display: flex;
        flex-direction: column;
        justify-items: center;
    }
    .ShopList h2 {
        margin-bottom: 0;
    }

    .listControls button {
        margin-bottom: 1rem;
    }

    .itemName {
        text-align: left;
    }

    #saveShopBtn, .saveBtn {
        background-color: green;
    }

    #cancelSaveBtn, .cancelBtn {
        background-color: red;
    }
    .urlText {
        width: 100%
    }

    #editStoreName {
        border: none;
        border-radius: 0;
        background-color: inherit;
        padding: 0;
        margin-left: 1rem;
    }

    .formControl {
        margin-top: 1rem;
    }
</style>

<div class="ShopList">
    {#if $shop.items.length > 0}
    <h2>
        Welcome to {$shop.name}
        {#if !isViewingShop}
        <button id="editStoreName" on:click|preventDefault={showNewStoreNameDialog}><Icon data={pencil} /></button>
        {/if}
    </h2>
    <div class="outOfStockControl">
        <label for="oosCheckbox">Show out of Stock Items: </label>
        <input type=checkbox bind:checked={$showOutOfStock} />
    </div>
    {#if !$isViewingShop}
    <div class="listControls">
        <button on:click={showSaveDialog}>Save for others to use <Icon data={save} /></button>
        <button on:click={showAddNewDialog}>Add New Item <Icon data={plus} /></button>
    </div>
    {/if}
    <table class="ShopListHeader">
        <tr>
            <th class="itemName"><strong>Item</strong></th>
            <th class="entry"><strong>Weight (lbs)</strong></th>
            <th class="entry"><strong>Price (gp)</strong></th>
            <th class="entry"><strong>Stock</strong></th>
            {#if !$isViewingShop}<th class="controls"></th>{/if}
        </tr>
        {#each $shop.items as item (item.name)}
            {#if item.stocked_quantity > 0 || $showOutOfStock}
                <ShopItem {...item} on:updatedItem={updateItem} on:deleteItem={deleteItem}/>
            {/if}
        {/each}
        </table>
    {:else}
        <p>No Items for the store</p>
    {/if}
    {#if !$isViewingShop}
    <dialog bind:this={confirmSaveDlg}>
        <form id="confirmSave">
            {#if error_message != "" }<ErrorCard {error_message} />{/if}
            <p>Saving is free for all right now</p>
            <p>However, to keep it free, if no one has viewed or used this store in 30 days, it will be deleted</p>
            <button id="saveShopBtn" on:click|preventDefault={saveStore}>Save</button>
            <button id="cancelSaveBtn" on:click|preventDefault={cancelSave}>Cancel</button>
        </form>
    </dialog>
    <dialog bind:this={addNewItemDlg}>
        <form>
            <label for="addName">Name</label>
            <input id="addName" type="text" bind:value={newName}><br>
            <label for="addDesc">Description</label>
            <textarea id="addDesc" bind:value={newDescription} cols=80 rows=10></textarea><br>
            <label for="addPrice">Price (gp)</label>
            <input id="addPrice" type="number" bind:value={newPrice}><br>
            <label for="addWeight">Weight (lbs)</label>
            <input id="addWeight" type="number" bind:value={newWeight}><br>
            <label for="addStock">Stock Quantity</label>
            <input id="addStock" type="number" bind:value={newStock}><br>
            <button class="saveBtn" on:click|preventDefault={addNewItem}>Save</button>
            <button class="cancelBtn" on:click|preventDefault={cancelAddNew}>Cancel</button>
        </form>
    </dialog>
    <dialog bind:this={urlDisplayDlg}>
        <p>You're Store has been saved to {ShopID}</p>
        <p>You can find it at</p>
        <div class="urlText">
            <input type="text" bind:value={ShopURL} disabled>
            <button class="saveBtn" on:click|preventDefault={copyUrlToClipboard}><Icon data={completeIcon} /></button>
        </div>
        <button class="cancelBtn" on:click|preventDefault={closeUrlDlg}>Close</button>
    </dialog>
    <dialog bind:this={changeStoreNameDlg}>
        <form>
            <p>Change the store name</p>
            <input type="text" bind:value={newStoreName}>
            <div class="formControl">
                <button class="saveBtn" on:click|preventDefault={saveNewStoreName}>Save</button>
                <button class="cancelBtn" on:click|preventDefault={cancelNewStoreName}>Cancel</button>
            </div>
        </form>
    </dialog>
    {/if}
</div>