Ball2[] ball2s;
int dt;
float ddt, e0;

void setup() {
  fullScreen();
  stroke(255);
  strokeWeight(0);
  noStroke();
  strokeCap(ROUND);

  dt=20;
  ddt=1.0/dt;
  ball2s=new Ball2[25];

  e0=0;
  for (int i=0; i<25; i++) {
    boolean ok;
    do {
      ok=true;
      ball2s[i]=new Ball2(new PVector(random(width), random(height)), PVector.fromAngle(random(TWO_PI)).mult(random(1, 2)), 175, 25, 4);
      if ((ball2s[i].p.x<=ball2s[i].r/2)||(ball2s[i].p.x>=width-ball2s[i].r/2)||(ball2s[i].p.y<=ball2s[i].r/2)||(ball2s[i].p.y>=height-ball2s[i].r/2)) {
        ok=false;
      } else {
        for (int j=0; j<i; j++) {
          if (ball2s[i].r/2+ball2s[j].r/2>PVector.dist(ball2s[i].p, ball2s[j].p)) {
            ok=false;
            break;
          }
        }
      }
    } while (!ok);
  }

  for (int i=0; i<ball2s.length; i++) {
    for (int j=0; j<ball2s[i].balls.length; j++) {
      e0+=ball2s[i].balls[j].m*pow(ball2s[i].balls[j].v.mag(), 2);
    }
    e0+=ball2s[i].m*pow(ball2s[i].v.mag(), 2);
  }

  frameRate(30);
}

void draw() {
  background(0);
  for (int i=0; i<dt; i++) {
    for (int j=0; j<ball2s.length; j++) {
      ball2s[j].move(ddt);
      for (int k=ball2s.length-1; k>j; k--) {
        ball2s[j].checkBall(ball2s[k]);
      }
      ball2s[j].checkball(ddt);
    }
  }

  float e=0;
  for (int i=0; i<ball2s.length; i++) {
    for (int j=0; j<ball2s[i].balls.length; j++) {
      e+=ball2s[i].balls[j].m*pow(ball2s[i].balls[j].v.mag(), 2);
    }
    e+=ball2s[i].m*pow(ball2s[i].v.mag(), 2);
  }
  for (int j=0; j<ball2s.length; j++) {
    ball2s[j].show();
  }
  e=sqrt(e0/e);
  for (int i=0; i<ball2s.length; i++) {
    for (int j=0; j<ball2s[i].balls.length; j++) {
      ball2s[i].balls[j].v.mult(e);
    }
    ball2s[i].v.mult(e);
  }
}

class Ball {
  PVector p, pp, v, g;
  float r, m;

  Ball(PVector p_, PVector v_, float r_) {
    p=p_.copy();
    pp=p.copy();
    v=v_.copy();
    r=r_;
    m=r*r*25;
  }

  void move(float t) {
    pp=p.copy();
    p.add(v.copy().mult(t));
  }

  void show() {
    ellipse(p.x, p.y, r, r);
  }
}

class Ball2 {
  PVector p, v;
  float r, rr, m;
  Ball[] balls;

  Ball2(PVector p_, PVector v_, float r_, float rr_, int n_) {
    p=p_.copy();
    v=v_.copy();
    r=r_;
    rr=rr_;
    m=r*r;
    balls=new Ball[n_];
    for (int i=0; i<n_; i++) {
      boolean ok;
      do {
        ok=true;
        balls[i]=new Ball(PVector.fromAngle(random(TWO_PI)).mult(sqrt(random(pow(r/2-rr, 2)))).add(p), PVector.fromAngle(random(TWO_PI)).mult(random(1, 2)), rr);
        for (int j=0; j<i; j++) {
          if (balls[i].r/2+balls[j].r/2>PVector.dist(balls[i].p, balls[j].p)) {
            ok=false;
            break;
          }
        }
      } while (!ok);
    }
  }

  void move(float t) {
    p.add(v.copy().mult(t));
    if (p.x<=r/2||p.x>=width-r/2) {
      p.sub(v.copy().mult(t)); 
      v.x*=-1;
    }
    if (p.y<r/2||p.y>height-r/2) {
      p.sub(v.copy().mult(t)); 
      v.y*=-1;
    }
  }

  void checkBall(Ball2 ball) {
    if (p.dist(ball.p)<=r/2+ball.r/2) {
      PVector vv=p.copy().sub(ball.p).setMag(
        ball.v.copy().dot(p.copy().sub(ball.p).normalize()))
        .add(p.copy().sub(ball.p).copy().rotate(PI/2).setMag(
        v.copy().rotate(-PI/2).dot(p.copy().sub(ball.p).normalize())));
      ball.v=ball.p.copy().sub(p).setMag(
        v.copy().dot(ball.p.copy().sub(p).normalize()))
        .add(ball.p.copy().sub(p).copy().rotate(PI/2).setMag(
        ball.v.copy().rotate(-PI/2).dot(ball.p.copy().sub(p).normalize())));
      v=vv;
    }
  }

  void checkball(float t) {
    for (int i=0; i<balls.length; i++) {
      balls[i].move(t);
      for (int j=i+1; j<balls.length; j++) {
        if (balls[i].r/2+balls[j].r/2>PVector.dist(balls[i].p, balls[j].p)) {
          PVector v2=balls[i].p.copy().sub(balls[j].p).setMag(balls[j].v.copy().dot(balls[i].p.copy().sub(balls[j].p).normalize())).add(balls[i].p.copy().sub(balls[j].p).copy().rotate(PI/2).setMag(balls[i].v.copy().rotate(-PI/2).dot(balls[i].p.copy().sub(balls[j].p).normalize())));
          balls[j].v=balls[j].p.copy().sub(balls[i].p).setMag(balls[i].v.copy().dot(balls[j].p.copy().sub(balls[i].p).normalize())).add(balls[j].p.copy().sub(balls[i].p).copy().rotate(PI/2).setMag(balls[j].v.copy().rotate(-PI/2).dot(balls[j].p.copy().sub(balls[i].p).normalize())));
          balls[i].v=v2;
        }
      }
      if (p.copy().sub(balls[i].p).mag()>=r/2-balls[i].r/2) {
        PVector vv=p.copy().sub(balls[i].p).setMag(
          (m-balls[i].m)/(m+balls[i].m)*
          v.copy().dot(p.copy().sub(balls[i].p).normalize())+
          (balls[i].m*2)/(m+balls[i].m)*
          balls[i].v.copy().dot(p.copy().sub(balls[i].p).normalize()))
          .add(p.copy().sub(balls[i].p).copy().rotate(PI/2).setMag(
          v.copy().rotate(-PI/2).dot(p.copy().sub(balls[i].p).normalize())));
        balls[i].v=p.copy().sub(balls[i].p).setMag(
          (m*2)/(m+balls[i].m)*
          v.copy().dot(p.copy().sub(balls[i].p).normalize())+
          (balls[i].m-m)/(m+balls[i].m)*
          balls[i].v.copy().dot(p.copy().sub(balls[i].p).normalize()))
          .add(p.copy().sub(balls[i].p).copy().rotate(PI/2).setMag(
          v.copy().rotate(-PI/2).dot(p.copy().sub(balls[i].p).normalize())));
        v=vv;
      }
    }
  }

  void show() {
    fill(255);
    ellipse(p.x, p.y, r, r);
    fill(0);
    for (int i=0; i<balls.length; i++) {
      balls[i].show();
    }
  }
}
