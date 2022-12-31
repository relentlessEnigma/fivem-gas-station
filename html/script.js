$(function() {
    function display(bool) {
        if (bool) {
            $("#menu").show();
        } else {
            $("#menu").hide();
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

        $("#price").text("Gas Price: " + item.gasPrice);
        $("#tankDamage").text("Tank Health: " + item.tankDamage)
        $("#amountMax").text("Maximum you can fill is: " + item.amountMax + "€€")
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
        $.post('https://gas-station/GasStation:fuelfull', JSON.stringify({amount: $('#quantity').val()}));
        $.post('https://gas-station/GasStation:ui-off', JSON.stringify({}));
    });
});
