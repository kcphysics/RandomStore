<script>
    import Icon from 'svelte-awesome';
    import coffee from 'svelte-awesome/icons/coffee';
</script>

<style>
    .footer {
        flex-shrink: 0;
        background-color: #070600;
        color: white;
        text-align: center;
        margin-top: auto
    }

    .footer a,
    .footer p {
        font-size: small;
    }
</style>

<div class="footer">
    <a href="https://www.flaticon.com/free-icons/shop" title="shop icons">Shop Favicon created by Freepik - Flaticon</a>
    <p>This is an open source project, made from passion.<br><a href="https://bmc.link/kcphysics">Consider buying the developer a <Icon data={coffee} /></a></p>
</div>