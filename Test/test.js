const canvas = document.getElementById("myCanvas");
const ctx = canvas.getContext("2d");

const ballRadius = 10;
const paddleHeight = 10;
const paddleWidth = 75;

const brickRowCount = 5;
const brickColumnCount = 15;
const brickPadding = 0;
const brickOffsetTop0 = 30;
let brickOffsetTop = brickOffsetTop0;
const brickOffsetLeft = 0;
const defaultColor="#ffffffff";

// Calculate brick width to fit nicely
// 400 is the width we want to fit them in
// subtract offsets and padding
// 400 () canvas width - 60 (offsets) = brickOffsetLeft * (brickColumnCount-1) +  brickWidth * brickColumnCount
// solve for brickWidth
// brickWidth = (480 - 60 - (brickPadding* (brickColumnCount-1)) ) / brickColumnCount
let brickWidth =(480 - brickOffsetLeft*2 - (brickPadding* (brickColumnCount-1)) ) / brickColumnCount
let brickHeight = 30;
let doomtick=50;
let doomtimer=doomtick;
// Load paddle image
let paddleImg = new Image();
paddleImg.src = "assets/paddle.png"; // Use your image path


// Background image
function setupBg(loc,num){
    bgImageLoaded = true;
    let src = loc+num+".jpg";
    bgImage.src = src;
}
function safeBg(){
    if (bgImageLoaded) {
        ctx.drawImage(bgImage, 0, 0, 480, 320);
    } else {
        ctx.fillStyle = "#2c2727ff"; // or any color you want
        ctx.fillRect(0, 0, 480, 320);
    }
}
// Define the background image object and catch loading errors
let bgImageLoaded = false;
let bgImage = new Image();
bgImage.onerror = function() {
  bgImageLoaded = false;
};
// default background
setupBg("assets/background","00");

let gamestate = "start"; // "start", "playing", "gameover"
let lives = 3;
let level=1;
let justdied=false;
let paddleX = (canvas.width - paddleWidth) / 2;
let x = canvas.width / 2;
let y = canvas.height - 30;
let dx0 = 2;
let dy0 = -(2+level);
let dx = dx0;
let dy = dy0;
let score = 0;
let totalscore = 0;
let bricks = [];
ctx.fillStyle = defaultColor;

function randomColor() {
    const r = Math.floor(Math.random() * 128+128);
    const g = Math.floor(Math.random() * 128+128);
    const b = Math.floor(Math.random() * 128+128);
    return `rgb(${r},${g},${b})`;
}
// Create bricks array
function createBricks() {
    //clear old bricks
    bricks = [];
    for (let c = 0; c < brickColumnCount; c++) {
    bricks[c] = [];
    for (let r = 0; r < brickRowCount; r++) {
        bricks[c][r] = { x: 0, y: 0, status: 1, color: randomColor()};
    }
    }
}
// Collision detection helper function
function circleRectCollision(cx, cy, radius, 
                        rx, ry, rw, rh) {
  // Find the closest point to the circle within the rectangle
  let closestX = Math.max(rx, Math.min(cx, rx + rw));
  let closestY = Math.max(ry, Math.min(cy, ry + rh));
  // Calculate the distance between the circle's center and this closest point
  let dx = cx - closestX;
  let dy = cy - closestY;
  // If the distance is less than the radius, collision!
  if((dx * dx + dy * dy) <= (radius * radius)){
    if(dx*dx<dy*dy){ // Hit the top or bottom
        return(1)
    }else{ // Hit the sides
        return(2)
    }
  }
  return(false)
}
// Collision detection for bricks
function collisionDetection() {
  changedx=false;
  changedy=false;
  brickstoolow=false;
  for (let c = 0; c < brickColumnCount; c++) {
    for (let r = 0; r < brickRowCount; r++) {
      const b = bricks[c][r];
      if (b.status === 1) {
        // Check for collision
        collisiionType=circleRectCollision(x, y, ballRadius, b.x, b.y, 
                brickWidth, brickHeight)
        if (collisiionType>0){
          if(collisiionType==1){
            changedy=true;
          }else{
            changedx=true;
          }
          b.status = 0;
          // update score
          score++;
          totalscore++;
          if (score === brickRowCount * brickColumnCount) {
              gamestate = "win";
          }
        }
        // check if brick has gone too low
        if(b.y+brickHeight>canvas.height){
            b.status=0;
            brickstoolow=true;
        }
      }
    }
  }
  if(changedx){
    dx = -dx;
  }
  if(changedy){
    dy = -dy;
  }
  if(brickstoolow){
    loseLife();
  }
}

function drawScore() {
  ctx.font = "16px Arial";
  ctx.fillStyle = defaultColor;
  ctx.fillText(`Level: ${level}, Score: ${totalscore}`, 8, 20);
}

function drawLives() {
  ctx.font = "16px Arial";
  ctx.fillStyle = defaultColor;
  ctx.fillText(`Lives: ${lives}`, canvas.width - 65, 20);
}

function drawBricks() {
  for (let c = 0; c < brickColumnCount; c++) {
    for (let r = 0; r < brickRowCount; r++) {
      if (bricks[c][r].status === 1) {
        const brickX = c * (brickWidth + brickPadding) + brickOffsetLeft;
        const brickY = r * (brickHeight + brickPadding) + brickOffsetTop;
        bricks[c][r].x = brickX;
        bricks[c][r].y = brickY;
        ctx.beginPath();
        ctx.rect(brickX, brickY, brickWidth, brickHeight);
        ctx.fillStyle = bricks[c][r].color;
        ctx.fill();
        ctx.closePath();
      }
    }
  }
}

function drawBall() {
  ctx.beginPath();
  ctx.arc(x, y, ballRadius, 0, Math.PI * 2);
  ctx.fillStyle = defaultColor;
  ctx.fill();
  ctx.closePath();
}

function drawPaddle() {
  // Draw the paddle image if loaded, else fallback to rectangle
  if (paddleImg.complete && paddleImg.naturalWidth !== 0) {
    ctx.drawImage(paddleImg, paddleX, canvas.height - paddleHeight, paddleWidth, paddleHeight);
  }else{
    ctx.beginPath();
    ctx.rect(paddleX, canvas.height - paddleHeight, paddleWidth, paddleHeight);
     ctx.fillStyle = defaultColor;
    ctx.fill();
    ctx.closePath();
  }
}

function loseLife() {
  lives--;
  if (!lives) {
     gamestate = "gameover";
  }else {
            x = canvas.width / 2;
            y = canvas.height - 30;
            dx = dx0;
            dy = dy0 - level;
            doomtimer=doomtick;
            paddleX = (canvas.width - paddleWidth) / 2;
            justdied=true;
            gamestate = "paused";
  }
} 

// Collision detection for walls and paddle
function paddleandwallDetection() {
  if (y + dy < ballRadius) { // Top wall
    dy = -dy;
  } else if (y + dy > canvas.height - ballRadius) { // Bottom wall
    if (x > paddleX && x < paddleX + paddleWidth) { // Paddle
        // make the ball x direction depend on where it hit the paddle
        dx = 8 * ((x-(paddleX+paddleWidth/2))/paddleWidth);
      dy = -dy;
    } else {// Missed paddle
      loseLife()
      return;
    }
  }
  if (x + dx < ballRadius || x + dx > canvas.width - ballRadius) {
    dx = -dx;
  }
}

function draw() {
  // Only called during 'playing' state
  safeBg();
  paddleandwallDetection();
  collisionDetection();
  drawBall();
  drawPaddle();
  drawBricks();
  drawScore();
  drawLives();
  x += dx;
  y += dy;
}


function mainLoop() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  if (gamestate === "playing") {
    setupBg("assets/background",("0"+level).slice(-2));
    doomtimer--;
    if(doomtimer<=0){
        brickOffsetTop+=1;
        doomtimer=doomtick;
    }
    draw();
  } else{
    setupBg("assets/background","00");
    safeBg();
    ctx.font = "24px serif";
    ctx.textAlign = "center";
  } if (gamestate === "start") {
    ctx.fillText("Click to play!", canvas.width/2, canvas.height/2);
  } else if (gamestate === "gameover") {
    ctx.fillText("Click to restart", canvas.width/2, canvas.height/2 + 50);
    ctx.font = "48px serif";
    ctx.fillText("YOUR SCORE: "+totalscore, 
        canvas.width/2, canvas.height/2-50);
    ctx.fillText("GAME OVER", canvas.width/2, canvas.height/2);
  } else if (gamestate === "win") {
    ctx.fillText("Click for next level...", canvas.width/2, canvas.height/2 + 100);
    ctx.font = "48px serif";
    ctx.fillText("LEVEL " + level, canvas.width/2, canvas.height/2-50);  
    ctx.fillText("COMPLETED!" , canvas.width/2, canvas.height/2);  
  }else if (gamestate === "paused") {
    ctx.fillText("Press escape or click to continue.", 
        canvas.width/2, canvas.height/2 + 100);
    ctx.font = "48px serif";
    if(justdied){
    ctx.fillText("FIND YOUR FOCUS!", 
        canvas.width/2, canvas.height/2-100);
    ctx.fillText("LIVES LEFT: " + lives, 
        canvas.width/2, canvas.height/2);
    }else{
        ctx.fillText("PAUSED...", canvas.width/2, canvas.height/2);
    }
  }
  ctx.textAlign = "left";
}

function startGame(newlevel) {
  // Reset game variables
  level=newlevel;
  createBricks();
  x = canvas.width / 2;
  y = canvas.height - 30;
  //randomize starting direction a bit
  dx = Math.floor(Math.random() * 2+1)* Math.sign(Math.random() * 2-1);
  dy = -(2+level);
  paddleX = (canvas.width - paddleWidth) / 2;
  if(newlevel==1){
      lives = 3;
      totalscore=0;
    }else{
      doomtick=doomtick*0.9;
    } 
  brickOffsetTop = brickOffsetTop0;
  doomtimer=doomtick;
  score = 0;
  gamestate = "playing";
}

function handleStartRestart(e) {
  if (gamestate === "start" || gamestate === "gameover") {
    startGame(1);
  }else if(gamestate === "win"){
    startGame(level+1);
  }else if (gamestate === "paused" || gamestate === "playing"){
    pauseUnpause();
  }
  setupBg("assets/background",("0"+level).slice(-2));
}

function gameLoop() {
  mainLoop();
  requestAnimationFrame(gameLoop);
}

gameLoop();


document.addEventListener("click", mouseClickHandler, false);
document.addEventListener("mousemove", mouseMoveHandler, false);
document.addEventListener("keydown", keyDownHandler, false);

function mouseClickHandler(e) {
    handleStartRestart(e);
}

function pauseUnpause() {
    if (gamestate === "playing") {
        gamestate = "paused";
    }else if (gamestate === "paused") {
        gamestate = "playing";
        justdied=false;
    }
}

function mouseMoveHandler(e) {
  const relativeX = e.clientX - canvas.offsetLeft;
  if (relativeX > 0 && relativeX < canvas.width) {
    paddleX = relativeX - paddleWidth / 2;
  }
}

function keyDownHandler(e) {
    // pause/unpause game
  if (e.key === "Escape") {
    pauseUnpause();
  }
}