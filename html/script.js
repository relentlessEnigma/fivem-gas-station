$(function() {
    function display(bool) {
        if (bool) {
            $(".box").show();
        } else {
            $(".box").hide();
        }
    }

    var gasPrice = 0 

    display(false)

    window.addEventListener('message', function(event) {
        var item = event.data;
        gasPrice = item.gasPrice;

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
        $("#amountMax").text("Price to total fill: " + item.amountMax.toFixed(2) + "€")
    })

    document.onkeyup = function(data) {
        if(data.key == "Escape") {
            $.post('https://gas-station/GasStation:ui-off', JSON.stringify({}));
            return
        }
    };

    $("#buttonclick").click(function() {
        $.post('https://gas-station/GasStation:fuel', JSON.stringify(
            {
                amount: $('#quantity').val(),
                gasPrice: gasPrice
            }));
        $.post('https://gas-station/GasStation:ui-off', JSON.stringify({}));
    });

    $("#atestar").click(function() {
        $.post('https://gas-station/GasStation:fuelfull');
        $.post('https://gas-station/GasStation:ui-off', JSON.stringify({}));
    });
});
