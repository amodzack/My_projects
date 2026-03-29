clear

% checking robo connection in usb
robo = legoev3('usb');


% getting all details of robo with connected sensors 
beep(robo)

% Sensors delcaration 
touch_rl = touchSensor(robo,1) ; %Bottom sensor monitoring rightleft motion

touch_ud = touchSensor(robo,3);  %Top sensor monitoring up down motion

us = sonicSensor(robo,2);   % Ultrasonic sensor

% Declaring all motors
up_down = motor(robo,'B') ; %motor moving link up and down

right_left = motor(robo,'C'); % motor moving link right and left

gripper = motor(robo,'A');  % motor for finger grip

%%main function callisng as per task
assignment(robo)

%Calling functions as per the assignment
function assignment(robo)
    home(robo);
    pause(2);
    p_up(robo);
    go_s1(robo);
    p_down(robo);
    go_home(robo);
    go_s1(robo);
    p_up(robo);
    go_s2(robo);
    p_down(robo);
    go_home(robo);
    go_s2(robo);
    p_up(robo);
    go_s1(robo);
    p_down(robo);
    go_home(robo);
    go_s1(robo);
    p_up(robo);
    go_home(robo);
    p_down(robo);
    horn(robo);
end

% Play beep sounds 
function horn(robo)
pause(0.5);
beep(robo);
pause(0.25);
beep(robo);
pause(0.25)
for i = 0:30
    beep(robo);
end
pause(0.5);
beep(robo);
pause(0.25);
for i = 0:30
    beep(robo);
end
beep(robo);
end

%%homing START
function home(robo)
    touch_rl = touchSensor(robo,1)  %Bottom sensor monitoring rightleft motion
    touch_ud = touchSensor(robo,3)  %Top sensor monitoring up down motion
    us = sonicSensor(robo,2)   % Ultrasonic sensor

    % Declaring all motors
    up_down = motor(robo,'B')  
    right_left = motor(robo,'C') 
    gripper = motor(robo,'A') 

    % Start homing procedure
   disp('Starting homing procedure...');

   % Homing motor B (Up/Down)
   disp('Homing motor B (Up/Down)...');
     if readTouch(touch_ud)
         disp('Touch sensor : touch_ud is already pressed. Releasing motor...');
         down(up_down, touch_ud);
         disp('Sensor unpressed. Ready to home.');
     end

   % Move the motor up
   up(up_down, touch_ud);
   resetRotation(up_down); % Reset encoder value to 0 for homing position
   disp('Motor B homed.');

   % Homing motor A (Right/Left)
   disp('Homing motor A (Right/Left)...');
     if readTouch(touch_rl)
         disp('Touch sensor : touch_rl is already pressed. Releasing motor...');
         left(right_left, touch_rl);
         disp('Sensor unpressed. Ready to home.');
     end

   % Move motor to the right
   right(right_left, touch_rl);
   resetRotation(right_left); % Reset encoder value to 0 for homing position

   % Homing procedure for motor A
  run_rl (right_left, 'left',90)
   disp('Motor A homed.');

   % Homing the gripper
   start(gripper, 25);
   disp('Running gripper motor for 2 secs');
   pause(0.2);
   gripper.Speed = 0;
   resetRotation(gripper); % Reset gripper encoder value

   % Open the gripper
   openGripper(gripper);
   disp('Gripper homed.');

   % Play beep sounds
     for i = 0:30
         beep(robo);
     end
   pause(0.5);
   beep(robo);
   pause(0.25);
   beep(robo);
   resetRotation(right_left);
   resetRotation(up_down);

end
%homing end


%Open and Closing combined functions%
%Sub function of homing
function closeGripper(gripper)
    start(gripper, 25);
    pause(.5)
    gripper.Speed = 0;
    resetRotation(gripper);
end

%Sub function of homing
function openGripper(gripper)
    closeGripper(gripper);
    a=readRotation(gripper) ;
    start (gripper, -25);
      while (readRotation(gripper) -a )>= -70

      end
    gripper.Speed = 0;
end


%Initializing functions to check
function up(up_down,touch_ud)
    start(up_down, -25);
      while ~readTouch(touch_ud)
          %pause(0.1);
      end
    up_down.Speed = 0;
end

function down(up_down,touch_ud)
    start(up_down, 05);
      while readTouch(touch_ud) % run loop such that it checks when it touches
          %pause(0.1);  
      end
    up_down.Speed = 0
end

function left(right_left,touch_rl)
    start(right_left, -15);
      while readTouch(touch_rl) % run loop such that it checks when it touches
          %pause(0.1);
      end
    right_left.Speed = 0
end

function right(right_left,touch_rl)
    start(right_left, 15);
      while ~readTouch(touch_rl)
          %pause(0.1);
      end
    right_left.Speed = 0;
end

%pickup function
% goes down picks and comes back to its position
function pickup(robo)
    up_down = motor(robo,'B') ;
    us = sonicSensor(robo,2); 
    touch_ud = touchSensor(robo,3);
    gripper = motor(robo,'A')

   start (up_down, 15)
   y=0;
   x=readDistance(us)
     while x~=y
         pause (0.25);
         y=x;
         x=readDistance(us);
     end
   up_down.Speed = 0
   start (up_down, -15)
   pause (0.25);
   up_down.Speed = 0
   closeGripper(gripper)
   pause(0.5)
   up(up_down,touch_ud) 
   disp('picked_up...');
end


%dropdown function
%goes down drops and comes back up
function dropdown(robo)
    up_down = motor(robo,'B') ;
    us = sonicSensor(robo,2); 
    touch_ud = touchSensor(robo,3);
    gripper = motor(robo,'A')
    start (up_down, 15)
    y=0;
    x=readDistance(us)
      while x~=y
          pause (0.25);
          y=x;
          x=readDistance(us);
      end
    up_down.Speed = 0
    start (up_down, -15)
    pause (0.25);
    up_down.Speed = 0
    openGripper(gripper)
    pause(0.5)
    up(up_down,touch_ud)  
    disp('dropped_down...');
end

%giving coordinates of S1, S2 and home positions
function  go_home(robo)
    Kp1=0.1
    Ki1=0.01
    right_left = motor(robo,'C'); 
    l=0
    m=0
% reset angle rotation before rotating
  if readRotation(right_left)>0
      start(right_left);
        while readRotation(right_left) >= 0
            % Wait until the motor reaches the home position
            n=readRotation(right_left)
            l=l+n
            m=Kp1*n+Ki1*l
            right_left.Speed=-m/3
        end
      right_left.Speed = 0;

  elseif readRotation(right_left)<0
      start(right_left);
        while readRotation(right_left) <= 0
          % Wait until the motor reaches the home position
          n=-readRotation(right_left)
          l=l+n
          m=Kp1*n+Ki1*l
          right_left.Speed=m/3
        end
      right_left.Speed = 0;
  end
  disp('homed..');

end

function go_s1(robo)
    %right_left = motor(robo,'C'); 
    xend=0;
    yend=45;
    theta1(xend,yend,robo);
    disp('S1_reached...');
end

function go_s2(robo)
    %right_left = motor(robo,'C'); 
    xend=-45;
    yend=-45;
    theta1(xend,yend,robo);
    disp('S2_reached...');
end

function theta1(xend,yend,robo)
    right_left = motor(robo,'C');
    %%%%%%%%%%%%%%%
    %xend=-45;
    %yend=50;
    %%%%%%%%%%%%%%%%%
    y1=(yend);
    x1=(xend);
    theta1 = atan2(y1, x1);  % theta will be the angle in radians (resulting from coordinates (x, y))
    theta1_deg = rad2deg(theta1);  % Converts radians to degrees
    %theta1_deg = 180-theta1_deg
    disp('Calculated theta1 ');
    disp('theta1_deg =');
    disp(theta1_deg)
    theta1= theta1_deg;
    Kp1=0.1
    Ki1=0.01
      if readRotation(right_left)>0
        start(right_left);
        l=0
        m=0
          while readRotation(right_left) >= 0
              % Wait until the motor reaches the home position
              n=readRotation(right_left)
              l=l+n
              m=Kp1*n+Ki1*l
              right_left.Speed=-m/3
          end
        right_left.Speed = 0;

      elseif readRotation(right_left)<0
        start(right_left, 15);
        l=0
        m=0
          while readRotation(right_left) <= 0
              % Wait until the motor reaches the home position
              n=-readRotation(right_left)
              l=l+n
              m=Kp1*n+Ki1*l
              right_left.Speed=m/3
          end
        right_left.Speed = 0;
      end

      if theta1>0
         theta1= 180- theta1;
         run_rl (right_left, 'right', theta1)

      elseif theta1<0
         theta1= 180+theta1
         run_rl (right_left, 'left', theta1)


      elseif theta1== 180 || theta1== -180
         theta1=0
      end

      if theta1 <0 
         direction = 'right'
      elseif theta1>0
             direction = 'left'
      end
  angle= theta1

end


function run_rl (right_left, direction,angle)
    m=0
    b=0
    Kp1=0.1
    Ki1=0.01

      if strcmp(direction, 'left')
        a = readRotation(right_left);
        start(right_left);
          while (a-readRotation(right_left)) <= (angle * 3)
              %PI Controller
             c= (angle * 3)+(readRotation(right_left))
             m= m+ c
             b= Kp1* c + Ki1*m
             right_left.Speed= -b/3
          end
        right_left.Speed = 0;
        disp ('moving left');
      end

      if strcmp(direction, 'right') 
        a = readRotation(right_left);
        start(right_left, 15);
          while (readRotation(right_left)-a) <= (angle * 3)
             %PI Controller
             c= (angle * 3)-(readRotation(right_left))
             m= m+ c
             b= Kp1* c + Ki1*m
             right_left.Speed= b/3
          end
        right_left.Speed = 0;
        disp ('moving right');
      end

end


%theta2
function theta2(robo,edge)
    us = sonicSensor(robo,2);
    gripper = motor(robo,'A');
    up_down = motor(robo,'B') ; 
    q=(readDistance(us))*1000
    zend=q-100;
    theta2 = 45 + (asind((zend-57.175)/185)); 
    disp('theta2 Calculated');
    disp('theta2= ');
    disp(theta2)
    run_ud(up_down,'down',theta2)
      if strcmp(edge, 'p_up')
        closeGripper(gripper)
        pause(0.5)
      end
     if strcmp(edge, 'p_down')
       openGripper(gripper)
       pause(0.5)
     end
    run_ud(up_down,'up', theta2)

end


function run_ud(up_down, direction,angel)
    angle= int32(angel)
    Kp2= 0.25
    Ki2=0.001

      if strcmp(direction, 'down')
        a = readRotation(up_down);
        start(up_down);
        %%%PID for moving down
        j = 0
        k = 0
        a = readRotation(up_down)
          while (readRotation(up_down)-a) <= (angle * 5)
              j =(angle * 5)-readRotation(up_down)
              k = k+ j
              l = Kp2*j + Ki2*k+10
              up_down.Speed=l/3
          end
        up_down.Speed = 0;
        disp ('moving down');
      end

      if strcmp(direction, 'up') 
        a = readRotation(up_down);
        start(up_down);
        %%%PID for moving up
        j=0
        k=0
          while (a-readRotation(up_down)) <=  (angle * 5)
              j=a+readRotation(up_down)- (angle * 5)
              k= k+ j
              l= Kp2*j + Ki2*k+40
              up_down.Speed=-l/3
          end
        up_down.Speed = 0;
        disp ('moving up');
      end
end


function p_up(robo)
    touch_ud = touchSensor(robo,3);   
    up_down = motor(robo,'B') ; 
    gripper = motor(robo,'A'); 
    edge ='p_up'
    theta2(robo,edge);
    disp ('picked up from the station');
end

function p_down(robo)
    edge='p_down'
    touch_ud = touchSensor(robo,3);   
    up_down = motor(robo,'B') ; 
    gripper = motor(robo,'A'); 
    theta2(robo,edge);
    disp ('dropped down from the station');
end