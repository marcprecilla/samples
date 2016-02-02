var GAME = {
    MOUSE: {
        mouseDown : 0,
        previousX : 0,
        previousY : 0,
        posx : 0,
        posy : 0,
        mouseMoveFunc: {},
        getMousePosition: function(eventArgs) {
            return false

            var e;

            if (!eventArgs)
                e = window.event;
            else {
                e = eventArgs;
            }

            if (e.offsetX || e.offsetY) {
                GAME.MOUSE.posx = e.offsetX;
                GAME.MOUSE.posy = e.offsetY;
            }
            else if (e.clientX || e.clientY) {
                GAME.MOUSE.posx = e.clientX;
                GAME.MOUSE.posy = e.clientY;
            }

            if (e.preventDefault)
                e.preventDefault();

        },
        onMouseMove: function(e) {
            return false

            if (!GAME.MOUSE.mouseDown)
                return;

            GAME.MOUSE.getMousePosition(e);

            GAME.MOUSE.mouseMoveFunc(GAME.MOUSE.posx, GAME.MOUSE.posy, GAME.MOUSE.previousX, GAME.MOUSE.previousY);

            GAME.MOUSE.previousX = GAME.MOUSE.posx;
            GAME.MOUSE.previousY = GAME.MOUSE.posy;
        },

        registerMouseMove: function(elem, func) {
            return false

            elem.onmousemove = GAME.MOUSE.onMouseMove;

            GAME.MOUSE.mouseMoveFunc = func;
        }
    },
    container_width: 0,
    container_height: 0,
    pad : {},
    ball : {},
    svg : {},
    message : {},

    // Ball
    ballRadius : 0,
    ballX: 0,
    ballY: 0,
    previousBallPosition : { x: 0, y: 0 },
    ballDirectionX: 0,
    ballDirectionY: 0,
    ballSpeed : 10,

    // Pad
    padWidth : {},
    padHeight : {},
    padX: 0,
    padY: 0,
    padSpeed : 0,
    inertia : 0.80,

    // Bricks
    bricks : [],
    destroyedBricksCount: 0,
    brickWidth : 50,
    brickHeight : 20,
    bricksRows : 5,
    bricksCols : 20,
    bricksMargin : 15,
    bricksTop : 20,

    // Misc.
    minX : 0,
    minY : 0,
    maxX: 0,
    maxY: 0,
    gameIntervalID : -1,
    startDate: 0,
    turbomode: false,
    collideWithWindow : function() {
        if (GAME.ballX < GAME.minX) {
            GAME.ballX = GAME.minX;
            GAME.ballDirectionX *= -1.0;
        }
        else if (GAME.ballX > GAME.maxX) {
            GAME.ballX = GAME.maxX;
            GAME.ballDirectionX *= -1.0;
        }

        if (GAME.ballY < GAME.minY) {
            GAME.ballY = GAME.minY;
            GAME.ballDirectionY *= -1.0;
        }
        else if (GAME.ballY > GAME.maxY) {
            GAME.ballY = GAME.maxY;
            GAME.ballDirectionY *= -1.0;
            //GAME.lost();
        }
    },
    collideWithPad : function() {
        if (GAME.turbomode)
            return;

        if (GAME.ballX + GAME.ballRadius < GAME.padX || GAME.ballX - GAME.ballRadius > GAME.padX + GAME.padWidth)
            return;

        if (GAME.ballY + GAME.ballRadius < GAME.padY)
            return;

        GAME.ballX = GAME.previousBallPosition.x;
        GAME.ballY = GAME.padY - GAME.ballRadius; // GAME.ballY = GAME.previousBallPosition.y;
        GAME.ballDirectionY *= -1.0;

        var dist = GAME.ballX - (GAME.padX + GAME.padWidth / 2);

        GAME.allDirectionX = 2.0 * dist / GAME.padWidth;

        var square = Math.sqrt(GAME.ballDirectionX * GAME.ballDirectionX + GAME.ballDirectionY * GAME.ballDirectionY);
        GAME.ballDirectionX /= square;
        GAME.ballDirectionY /= square;

    },
    movePad : function() {

        GAME.padX += GAME.padSpeed;

        GAME.padSpeed *= GAME.inertia;

        if (GAME.padX < GAME.minX)
            GAME.padX = GAME.minX;

        if (GAME.padX + GAME.padWidth > GAME.maxX)
            GAME.padX = GAME.maxX - GAME.padWidth;

        GAME.pad.setAttribute("x", GAME.padX);
        GAME.padSpeed = 0;

    },
    checkWindow : function() {
        GAME.maxX = GAME.container_width - GAME.minX;
        GAME.maxY = GAME.container_height + GAME.minY;
        GAME.padY = GAME.maxY - 50;
    },
    gameLoop : function() {
        //GAME.movePad();

        // Movements
        GAME.previousBallPosition.x = GAME.ballX;
        GAME.previousBallPosition.y = GAME.ballY;
        GAME.ballX += GAME.ballDirectionX * GAME.ballSpeed;
        GAME.ballY += GAME.ballDirectionY * GAME.ballSpeed;

        // Collisions
        GAME.collideWithWindow();
        GAME.collideWithPad();

        // Bricks
        for (var index = 0; index < GAME.bricks.length; index++) {
            GAME.bricks[index].drawAndCollide();
        }

        // Ball
        GAME.ball.setAttribute("cx", GAME.ballX);
        GAME.ball.setAttribute("cy", GAME.ballY);

        // Pad
        //GAME.pad.setAttribute("x", GAME.padX);
        //GAME.pad.setAttribute("y", GAME.padY);

        // Victory ?
        if (GAME.destroyedBricksCount == GAME.bricks.length) {
            GAME.win();
        }
    },
    generateBricks : function() {
        GAME.svg = document.getElementById("svgRoot");

        // Removing previous ones
        for (var index = 0; index < GAME.bricks.length; index++) {
            GAME.bricks[index].remove();
        }

        // Creating new ones
        var brickID = 0;

        var center_x = 480;
        var center_y = 120;
        var radius = 45;

        var brickPositions = [
            {x:538, y:120, a: 0},
            {x:524, y:160.5, a: 30},
            {x:501.5, y:192, a: 60},
            {x:460, y:200, a: 90},
            {x:420.5, y:192, a: 120},
            {x:394, y:160.5, a: 150},
            {x:382, y:120, a: 180},
            {x:396, y:79.5, a: 210},
            {x:418.5, y:48, a: 240},
            {x:460, y:39, a: 270},
            {x:499.5, y:48, a: 300},
            {x:526, y:79.5, a: 330}
       ]

        _.each(brickPositions, function(item, index) {
            GAME.bricks[brickID++] = new Brick(item.x,item.y,item.a);
        })

        /*
        var offset = (GAME.container_width - GAME.bricksCols * (GAME.brickWidth + GAME.bricksMargin)) / 2.0;

        for (var x = 0; x < GAME.bricksCols; x++) {
            for (var y = 0; y < GAME.bricksRows; y++) {
                GAME.bricks[brickID++] = new Brick(offset + x * (GAME.brickWidth + GAME.bricksMargin), y * (GAME.brickHeight + GAME.bricksMargin) + GAME.bricksTop);
            }
        }
        */
    },
    lost : function() {
        clearInterval(GAME.gameIntervalID);
        GAME.gameIntervalID = -1;

        //GAME.message.innerHTML = "Game over !";
    },
    win : function() {
        clearInterval(GAME.gameIntervalID);
        GAME.gameIntervalID = -1;

        var end = (new Date).getTime();

        //GAME.message.innerHTML = "Victory ! (" + Math.round((end - GAME.startDate) / 1000) + "s)";

        $("#ad #f1 #message").removeClass('show').addClass('show')
        MILO.svg.shape_circle.setAttributeNS(null, "cx", 480);
        MILO.svg.shape_circle.setAttributeNS(null, "cy", 300);
        $('#ad #f1 #svgRoot rect').show();
        $('#svgRoot rect').hammer().off();
    },
    initGame: function() {

        GAME.container_width = $('#gameZone').innerWidth();
        GAME.container_height = $('#gameZone').innerHeight();

        GAME.pad = document.getElementById("pad");
        GAME.ball = document.getElementById("ball");
        GAME.svg = document.getElementById("svgRoot");
        GAME.message = document.getElementById("message");

        GAME.ballRadius = GAME.ball.r.baseVal.value;
        GAME.padWidth = GAME.pad.width.baseVal.value;
        GAME.padHeight = GAME.pad.height.baseVal.value;

        //GAME.message.style.visibility = "hidden";

        GAME.checkWindow();

        GAME.padX = (GAME.container_width - GAME.padWidth) / 2.0;

        GAME.ballX = GAME.container_width / 2.0;
        GAME.ballY = GAME.maxY - 80;

        GAME.previousBallPosition.x = GAME.ballX;
        GAME.previousBallPosition.y = GAME.ballY;

        GAME.padSpeed = 0;

        max = .9;
        min = .4;
        GAME.ballDirectionX = Math.random() * (max - min) + min;
        GAME.ballDirectionY = -1.0;

        GAME.generateBricks();

        // Pad
        GAME.pad.setAttribute("x", GAME.padX);
        GAME.pad.setAttribute("y", GAME.padY);

        GAME.gameLoop();

        /*
        GAME.MOUSE.registerMouseMove(document.getElementById("gameZone"), function (posx, posy, previousX, previousY) {
            GAME.padSpeed += (posx - previousX) * 0.2;
        });
        */

        window.onresize = GAME.initGame;


    },
    startGame: function() {
        GAME.initGame();

        GAME.destroyedBricksCount = 0;

        if (GAME.gameIntervalID > -1)
            clearInterval(GAME.gameIntervalID);

        GAME.startDate = (new Date()).getTime(); ;
        GAME.gameIntervalID = setInterval(GAME.gameLoop, 16);
    }


}

/*
document.body.onmousedown = function (e) {
    GAME.MOUSE.mouseDown = 1;
    GAME.MOUSE.getMousePosition(e);

    GAME.MOUSE.previousX = GAME.MOUSE.posx;
    GAME.MOUSE.previousY = GAME.MOUSE.posy;
};

document.body.onmouseup = function () {
    GAME.MOUSE.mouseDown = 0;
};
*/


// Brick function
function Brick(x, y, a) {
    var isDead = false;
    var position = { x: x, y: y, a: a };

    var rect = document.createElementNS("http://www.w3.org/2000/svg", "image");
    GAME.svg.appendChild(rect);

    rect.setAttribute("width", GAME.brickWidth);
    rect.setAttribute("height", GAME.brickHeight);
    rect.setAttributeNS('http://www.w3.org/1999/xlink','href','//stash.truex.com/milo/html-campaigns/windstream/assets/brick.png');

    this.drawAndCollide = function () {
        if (isDead)
            return;
        // Drawing
        rect.setAttribute("x", position.x);
        rect.setAttribute("y", position.y);

        rect.setAttribute("transform", "rotate(" + position.a + " " + (position.x + 23) + " " + (position.y + 10) +  ")");

        // Collision
        if (GAME.ballX + GAME.ballRadius < position.x || GAME.ballX - GAME.ballRadius > position.x + GAME.brickWidth)
            return;

        if (GAME.ballY + GAME.ballRadius < position.y || GAME.ballY - GAME.ballRadius > position.y + GAME.brickHeight)
            return;

        // Dead
        this.remove();
        isDead = true;
        GAME.destroyedBricksCount++;

        // Updating ball
        GAME.ballX = GAME.previousBallPosition.x;
        GAME.ballY = GAME.previousBallPosition.y;

        GAME.ballDirectionY *= -1.0;
    };

    // Killing a brick
    this.remove = function () {
        if (isDead)
            return;
        GAME.svg.removeChild(rect);
    };
}




window.addEventListener('keydown', function (evt) {
    switch (evt.keyCode) {
        // Left arrow
        case 37:
            GAME.padSpeed -= 30;
            GAME.movePad();
            MILO.inactivity = false;
            break;
        // Right arrow
        case 39:
            GAME.padSpeed += 30;
            GAME.movePad();
            MILO.inactivity = false;
            break;
    }
}, true);


