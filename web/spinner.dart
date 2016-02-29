/*
 * EnergyVampires
 * Copyright (c) 2015 Michael S. Horn
 * 
 * Northwestern University
 * 2120 Campus Drive
 * Evanston, IL 60208
 * http://tidal.northwestern.edu
 
 * This project was funded in part by the National Science Foundation.
 * Any opinions, findings and conclusions or recommendations expressed in this
 * material are those of the author(s) and do not necessarily reflect the views
 * of the National Science Foundation (NSF).
 */
part of EnergyVampires;


/*
 * Spin for the weather
 */
class Spinner {

  int WEDGES = 48;

  int SCALE = 25;

  int power = 400;  // 700 watts
  
  double watt = 0.0;
  
  // is the spinner currently spinning
  bool spinning = false;

  // dimensions on the screen  
  int x = 0, y = 0, width = 2048, height = 1536;
  
  // Drawing context
  CanvasRenderingContext2D ctx;
  Random rand = new Random();
  
  // tween for spinning to a set value
  Tween tween;
   
  // index displayed on the spinner
  int index = 0;
   
  // current rotation of the spinner
  double angle = 0.0;
   
  // angular force for spins
  double force = 0.0;
  
  // callback for when the spin is complete
  Function onDone = null;
  
  double posX = 0.0; //mouse move coordinators
  double posY = 0.0;
  
  double clickAngle = 0.0;//mouse click angle
  
  List<double> angleList = [];//to store the angles
  
  int rightPosition = 0;//the correct position user clicks
  int count = 0;
  int barFlag = 0;
  int colorFlag = 0;
  
  bool mouseDown = false;
  
//  ImageElement image = new ImageElement(src: "EM_energy.png");
  
  Spinner() {
   
    
    for (var i = 2; i < 13; i++){// to initialize the angle list
      angleList.add(-(12-i)*PI/12.0);
    }
    for (var i = 1; i < 11; i++){
          angleList.add(i*PI/12.0);
        }

    // Load canvas and drawing context
    CanvasElement canvas = querySelector("#spinner");
    width = canvas.width;
    height = canvas.height;
    ctx = canvas.getContext("2d");
    
    
    
    canvas.addEventListener('mousemove', (event) {getMousePos(canvas, event);});//to get the mouse coordinators
    
    canvas.addEventListener('click', (event) {// to change the power
      if(pow((posX-600),2)+pow((posY-768),2) < 450*450 && pow((posX-600),2)+pow((posY-768),2) > 250*250)
      {//if mouse click in the white spinner space
        print('You clicked ' + posX.toString() + posY.toString());
        clickAngle = atan2(posY-768, posX-600);//get the angle for this clicking
        List<double> temAngleList = [];//store the abs comparing this angle to the angle list
        for(var i = 0; i < 21; i++)
        {
          temAngleList.add((clickAngle - angleList[i]).abs());
        }
        rightPosition = temAngleList.indexOf(temAngleList.reduce(min));//get the min one
        rightPosition = rightPosition + 2; 
        power = rightPosition * 50;//get the new power
        barFlag = 1;
//        _barMove();
        _draw();
      }
      if(pow((posX-600),2)+pow((posY-768),2) < 50*50){
        spin();
      }
    });
    
// Detect mousedown
canvas.addEventListener("mousedown",  (event) {
  if(pow((posX-600),2)+pow((posY-768),2) < 450*450 && pow((posX-600),2)+pow((posY-768),2) > 250*250)
        {//if mouse click in the white spinner space
          print('You clicked ' + posX.toString() + posY.toString());
          clickAngle = atan2(posY-768, posX-600);//get the angle for this clicking
          List<double> temAngleList = [];//store the abs comparing this angle to the angle list
          for(var i = 0; i < 21; i++)
          {
            temAngleList.add((clickAngle - angleList[i]).abs());
          }
          rightPosition = temAngleList.indexOf(temAngleList.reduce(min));//get the min one
          rightPosition = rightPosition + 2; 
          if(rightPosition*50 == power)
          {
            mouseDown = true;
          }
        }
});

// Detect mouseup
canvas.addEventListener("mouseup",  (event) {
 mouseDown = false;
}, false);

// Draw, if mouse button is pressed
canvas.addEventListener("mousemove",  (event) {
 if (mouseDown) {
   if(pow((posX-600),2)+pow((posY-768),2) < 450*450 && pow((posX-600),2)+pow((posY-768),2) > 250*250)
           {//if mouse click in the white spinner space
             print('You clicked ' + posX.toString() + posY.toString());
             clickAngle = atan2(posY-768, posX-600);//get the angle for this clicking
             List<double> temAngleList = [];//store the abs comparing this angle to the angle list
             for(var i = 0; i < 21; i++)
             {
               temAngleList.add((clickAngle - angleList[i]).abs());
             }
             rightPosition = temAngleList.indexOf(temAngleList.reduce(min));//get the min one
             rightPosition = rightPosition + 2; 
             power = rightPosition * 50;
           }
 }
});
const oneSec = const Duration(seconds:1);
new Timer.periodic(oneSec, (Timer t) => _draw());
  }


  num powerToAngle(num p) {
    num alpha = (PI * 2) * (p / (WEDGES * SCALE)) - PI;
    //if (alpha < 0) alpha += 2 * PI;
    return alpha;
  }
  
  void getMousePos(canvas, evt) {
             var rect = canvas.getBoundingClientRect();
             posX = evt.client.x - rect.left;
             posY = evt.client.y - rect.top;
//             print(posX);
//             print(posY);
           }

/*
 * Spin the spinner
 */
  void spin() {
    if (!spinning) {
      spinning = true;
      force = 3 + rand.nextDouble() * 1;
      _animate();
    }
  }


/*
 * Reset spinner controls
 */
  void reset() {
    spinning = false;
    angle = 0.0;
    force = 0.0;
    _draw();
  }


  void setIndex(int i) {
    index = i;
    double incr = PI * 2 / WEDGES;
    angle = incr * index;
  }


  void _animate() {
    double incr = PI * 2 / WEDGES;
    if (force != 0) {
      print("if loop here");
      angle += force;
      force *= 0.975;//slow down
      print(angle);
      print("force:");
      print(force);
      if (force.abs() < 0.01) {//less than 0.01, stop
        force = 0.0;
        Sounds.playSound("tick");
        spinning = false;
      }
      print("timer actived");
     Timer timer = new Timer(const Duration(milliseconds: 20), _animate);//restart
    }
    print("while loop actived");
    while (angle > incr * index + incr * 0.5) {
      index++;
      print(index);
      if (index >= WEDGES) {
        index = 0;
        angle -= PI * 2;
      }
      if (index % 12 == 0) Sounds.playSound("tick");
    }
    print("draw!");
    _draw();
  }


  void _draw() {
    
    num cx = 300;
    num cy = 300;
    num r = 300;
    num arc = PI * 2 / WEDGES;
    
    num frameX = 1520;
    num frameY = 258;
    num radius = 5;
    
    ctx.globalAlpha = 1;
    
    ctx.clearRect(0, 0, width, height);
     
    ctx.font = '40px AvenirNext-Bold';
    ctx.textAlign = "left";
    ctx.textBaseline = "baseline"; 

    ctx.save();
        {
    ImageElement spaceShip = document.querySelector('#bar');
    if(barFlag == 1){
      ctx.drawImage(spaceShip, 304+count*15, 651);
      count = count + 1;
      Timer timer = new Timer(const Duration(milliseconds: 50), _draw);//restart
      if(count == 40)
      {
        count = 0;
        barFlag = 0;
      }
    }
        }
           ctx.restore(); 
           // outer ring
    ctx.save();
    {
    ctx.beginPath();
    ctx.arc(600, 768, 480, 0, PI * 2, true);
    ctx.fillStyle = '#446666';
    ctx.fill();
    }
    ctx.restore();
    
    ctx.save();
    {
    ctx.beginPath();
    ctx.rect(1472, 268, 350, 1000);
    ctx.fillStyle = '#446666';
    ctx.fill();
    }
    ctx.restore();
    
    //energy bar frame
    ctx.save();
    {                   
    ctx.fillStyle = '#44BBAA';
    ctx.strokeStyle='#44BBAA';
    ctx.lineWidth = 10;
    ctx.lineCap = 'round';
    ctx.beginPath(); 
    ctx.moveTo(frameX + radius, frameY); 
    ctx.lineTo(frameX + 350 - radius, frameY); 
    ctx.quadraticCurveTo(frameX + 350, frameY, frameX + 350, frameY + radius); 
    ctx.lineTo(frameX + 350, frameY + 1000 - radius); 
    ctx.quadraticCurveTo(frameX + 350, frameY + 1000, frameX + 350 - radius, frameY+ 1000); 
    ctx.lineTo(frameX + radius, frameY + 1000); 
    ctx.quadraticCurveTo(frameX, frameY + 1000, frameX, frameY + 1000 - radius); 
    ctx.lineTo(frameX, frameY + radius); 
    ctx.quadraticCurveTo(frameX, frameY, frameX + radius, frameY); 
    ctx.closePath(); 
    ctx.fill();
    ctx.stroke();
    }
    ctx.restore();
    
    ctx.save();
    {
    ctx.fillStyle = '#99CCAA';
    ctx.strokeStyle='#44BBAA';
    ctx.lineWidth = 10;
    ctx.lineCap = 'round';
    ctx.beginPath(); 
    ctx.moveTo(frameX + radius, (1258-0.9*power)); 
    ctx.lineTo(frameX + 350 - radius, (1258-0.9*power)); 
    ctx.quadraticCurveTo(frameX + 350, (1258-0.9*power), frameX + 350, (1258-0.9*power) + radius); 
    ctx.lineTo(frameX + 350, (1258-0.9*power) + 0.9*power - radius); 
    ctx.quadraticCurveTo(frameX + 350, (1258-0.9*power) + 0.9*power, frameX + 350 - radius, (1258-0.9*power)+ 0.9*power); 
    ctx.lineTo(frameX + radius, (1258-0.9*power) + 0.9*power); 
    ctx.quadraticCurveTo(frameX, (1258-0.9*power) + 0.9*power, frameX, (1258-0.9*power) + 0.9*power - radius); 
    ctx.lineTo(frameX, (1258-0.9*power) + radius); 
    ctx.quadraticCurveTo(frameX, (1258-0.9*power), frameX + radius, (1258-0.9*power)); 
    ctx.closePath(); 
    ctx.fill();
    ctx.stroke();
    }
    ctx.restore();

    
// power fill
 ctx.save();
 {
   ctx.fillStyle = "rgba(255, 255, 255, 0.2)";
   ctx.beginPath();
   ctx.moveTo(600,768);
   ctx.arc(600, 768, 460, PI, powerToAngle(power), false);
   ctx.strokeStyle='rgba(255, 255, 255, 0.2)';
   ctx.lineWidth = 20;
   ctx.lineCap = 'round';
   ctx.closePath();
   ctx.fill();
//   ctx.stroke();
 }
 ctx.restore();
//    
 var wattsdata = document.querySelector('#realdata');
// print(wattsdata.alt);
 watt = double.parse(wattsdata.alt);
 print(power);
 print("real watt number");
 print(watt);
// real data power fill
ctx.save();
{
ctx.fillStyle = "rgba(0, 255, 255, 0.2)";
ctx.beginPath();
ctx.moveTo(600,768);
ctx.arc(600, 768, 460, PI, powerToAngle(watt), false);
ctx.strokeStyle='rgba(255, 255, 255, 0.2)';
ctx.lineWidth = 20;
ctx.lineCap = 'round';
ctx.closePath();
ctx.fill();
//   ctx.stroke();
}
ctx.restore();

    ctx.save();
    for (int i=0; i<WEDGES; i++) {
      if (i * SCALE % 100 == 0) {
        ctx.fillStyle = '#ffffff';
        ctx.fillText("${i * SCALE}", 155, 768 - 20);
      }
      if(i * SCALE % 100 == 0){ 
      ctx.strokeStyle='#44BBAA';
      ctx.beginPath();
      ctx.moveTo(150, 768);
      ctx.closePath();
      ctx.lineWidth = 20;
      ctx.lineCap = 'round';
      ctx.lineTo(350, 768);
      if (i * SCALE % 50 == 0) {
        ctx.stroke();
      }
      }
      else
      {
        ctx.strokeStyle='#99CCAA';
              ctx.beginPath();
              ctx.moveTo(175, 768);
              ctx.closePath();
              ctx.lineWidth = 20;
              ctx.lineCap = 'round';
              ctx.lineTo(325, 768);
              if (i * SCALE % 50 == 0) {
                ctx.stroke();
      }
      }
      ctx.translate(600, 768);
      ctx.rotate(arc);
      ctx.translate(-600, -768);
    } 
    ctx.restore();

    
    ctx.save();
    {
      
      ctx.translate(600, 768);
      ctx.rotate(angle);
      ctx.translate(-600, -768);
      ImageElement spin = document.querySelector('#spin');
            ctx.drawImage(spin,225,743);
    }
    ctx.restore(); 
    
//spin button
ctx.save();
{
ctx.beginPath();
ctx.closePath();
} 
ctx.restore();

ImageElement barframe = document.querySelector('#barFrame');

        ctx.drawImage(barframe,1065,651);
        
        ctx.save();
            {
            ctx.beginPath();
            ctx.rect(1090, 946, 380, 315);
            ctx.fillStyle = '#44BBAA';
            ctx.strokeStyle = '#44BBAA';
            ctx.lineWidth = 10;
                ctx.lineCap = 'round';
            ctx.fill();
            }
            ctx.restore();
        
        ctx.save();
            {
              if(power >= 900){
            ctx.beginPath();
            ctx.rect(1520, 208, 350, 58);
            ctx.fillStyle = '#C1272D';
            ctx.strokeStyle = '#C1272D';
            ctx.lineWidth = 10;
                ctx.lineCap = 'round';
            ctx.fill();
            ctx.stroke();
            ctx.font = '40px AvenirNext-Bold';
                            ctx.fillStyle = '#ffffff';
                            ctx.fillText("WARNING!", 1566+20, 217+35);
                            }
              else
              {
                ctx.beginPath();
                            ctx.rect(1520, 208, 350, 58);
                            ctx.fillStyle = '#44BBAA';
                            ctx.strokeStyle = '#44BBAA';
                            ctx.lineWidth = 10;
                                ctx.lineCap = 'round';
                            ctx.fill();
                            ctx.stroke();
                            ctx.font = '40px AvenirNext-Bold';
                            ctx.fillStyle = '#ffffff';
                            ctx.fillText("GREAT!", 1566+50, 217+35);
              }
            }
            ctx.restore();
    
    ctx.font = '60px AvenirNext-Bold';
    ctx.fillStyle = '#ffffff';
    ctx.fillText("Info.", 1100 + 20, 990 + 45);
    
    ctx.font = '60px AvenirNext-Bold';
    ctx.fillStyle = '#F4B350';
    ctx.fillText("${power}", 1100 + 20, 1085 + 45);
    
    ctx.font = '60px AvenirNext-Bold';
    ctx.fillStyle = '#F39C12';
    ctx.fillText("${power}", 1100+ 20, 1168 + 45);
    
    ctx.font = '40px AvenirNext-Bold';
    ctx.fillStyle = '#ffffff';
    ctx.fillText("watts", 1261+ 20, 1099 + 30);
    ctx.fillText("dollars", 1261+ 20, 1182 + 30);

  
  }
}


