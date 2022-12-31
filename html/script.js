$(function() {
    function display(bool) {
        if (bool) {
            $(".box").show();
        } else {
            $(".box").hide();
        }
    }

    display(false)

    window.addEventListener('message', function(event) {
        var item = event.data;

        if(item.type == "ui") {
            if(item.visible == true) {
                display(true)
            } else {
                display(false)
            }
        }

        $(".form h2").text("Welcome to " + item.gasStationName)
        $(".form h4").text(item.gasStationAddress)
        $("#price").text("Gas Price: " + item.gasPrice)
        $("#tankDamage").text("Tank Health: " + item.tankDamage)
        if(item.amountMax == undefined) {
            item.amountMax = 0.00
        }
        $("#amountMax").text("Maximum you can fill is: " + item.amountMax.toFixed(2) + "€")
    })

    document.onkeyup = function(data) {
        if(data.key == "Escape") {
            $.post('https://gas-station/GasStation:ui-off', JSON.stringify({}));
            return
        }
    };

    $("#buttonclick").click(function() {
        $.post('https://gas-station/GasStation:fuel', JSON.stringify({amount: $('#quantity').val()}));
        $.post('https://gas-station/GasStation:ui-off', JSON.stringify({}));
    });

    $("#atestar").click(function() {
        $.post('https://gas-station/GasStation:fuelfull');
        $.post('https://gas-station/GasStation:ui-off', JSON.stringify({}));
    });
});
