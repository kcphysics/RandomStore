<script>
    import Logo from "../../public/store.png"
</script>

<style>
    .header {
        width: 100%;
        background-color: #070600;
        color: white;
        margin-bottom: 1rem;
    }

    .header .logo {
        filter: invert(40%);
        width: 8rem;
    }

    .titleContainer {
        position: relative;
        text-align: center;
    }

    .titleName {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        font-size: 4rem;
        color: white;
    }
</style>

<div class="header">
    <div class="titleContainer">
        <img src={Logo} alt="Store Logo" title="Store Logo" class="logo">
        <div class="titleName">RandomStore</div>
    </div>
</div>