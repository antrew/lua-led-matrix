do
    local CLOCK_PIN = 5
    local DATA_PIN = 7

    -- 0 to 7
    local intensity = 7

    -- display buffer
    -- element is a row
    -- a bin in an element is a pixel in a row
    local disBuffer = {}
    for y = 0, 7, 1 do
        disBuffer[y] = 0
    end

    local clockPin = CLOCK_PIN
    local dataPin = DATA_PIN

    gpio.mode(clockPin, gpio.OUTPUT)
    gpio.mode(dataPin, gpio.OUTPUT)

    gpio.write(clockPin, gpio.HIGH)
    gpio.write(dataPin, gpio.HIGH)

    function send(data)
        for i = 0, 7, 1 do
            gpio.write(clockPin, gpio.LOW)
            local bitValue
            if bit.isset(data, i) then
                bitValue = gpio.HIGH
            else
                bitValue = gpio.LOW
            end
            gpio.write(dataPin, bitValue)
            gpio.write(clockPin, gpio.HIGH)
        end
    end

    function sendCommand(cmd)
        gpio.write(dataPin, gpio.LOW)
        send(cmd)
        gpio.write(dataPin, gpio.HIGH)
    end

    function sendData(address, data)
        sendCommand(0x44)
        gpio.write(dataPin, gpio.LOW)
        send(bit.bor(0xC0, address))
        send(data)
        gpio.write(dataPin, gpio.HIGH)
    end

    function display()
        for i = 0, 7, 1 do
            sendData(i, disBuffer[i])

            gpio.write(dataPin, gpio.LOW)
            gpio.write(clockPin, gpio.LOW)
            gpio.write(clockPin, gpio.HIGH)
            gpio.write(dataPin, gpio.HIGH)
        end

        sendCommand(bit.bor(0x88, intensity))
    end

    function dot(x, y, draw)
        if draw then
            disBuffer[y] = bit.set(disBuffer[y], x)
        else
            disBuffer[y] = bit.clear(disBuffer[y], x)
        end
    end

    function demo()
        for y = 0, 7, 1 do
            for x = 0, 7, 1 do
                -- draw dot
                dot(x, y, true)
                display()
                tmr.delay(50)
                --clear dot
                dot(x, y, false)
                display()
                tmr.delay(50)
            end
        end
    end
    demo()
end
