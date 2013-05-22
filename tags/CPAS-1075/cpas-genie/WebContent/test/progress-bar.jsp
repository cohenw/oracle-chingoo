
<style type="text/css">
.meter-wrap{
    position: relative;
}

.meter-wrap, .meter-value, .meter-text {
    /* The width and height of your image */
    width: 155px; height: 30px;
}

.meter-wrap, .meter-value {
    background: #bdbdbd url(../image/meter-outline.png) top left no-repeat;
}

.meter-text {
    position: absolute;
    top:0; left:0;

    padding-top: 5px;

    color: #fff;
    text-align: center;
    width: 100%;
}
</style>

<div class="meter-wrap" id="meter-ex1" style="cursor: pointer">
    <div class="meter-value" style="background-color: rgb(77, 164, 243); width: 70%; ">
        <div class="meter-text">70%</div>
    </div>
</div>

