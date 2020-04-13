import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.analysis.*;
// we must import this package to create an AudioFormat object
import javax.sound.sampled.*;

Minim minim;
AudioSample wave;

//tcf variables

int N=256;
float f1= 16.0; //3.0;
float f2=32.0;

FFT fft;
int hlength= N-1;
int Lh;
int ti; 
int taumax;
float tcf[][] = new float[N][N];
float tfr[][] = new float[N][N];
float tcfslice [] = new float[N];
float sig256 []= new float[N];
float spectra []= new float[N];
float specslice []= new float[N];
float[] samples;
float sig [];

void setup()
{
  size(1024, 400, P3D);
  background(0);
  stroke(255);
  strokeWeight(1);

  minim = new Minim(this);
  
  //Create input signal
  SIGWD sig512 = new SIGWD(N);
  samples = sig512.compSig();

  // when we create a sample we need to provide an AudioFormat so 
  // the sound will be played back correctly.
  AudioFormat format = new AudioFormat( N, //waveSampleRate, // sample rate
    16, // sample size in bits
    1, // channels
    true, // signed
    true   // bigEndian
    );

  //// finally, create the AudioSample
  wave = minim.createSample( samples, // the samples
    format, // the format
    N     // the output buffer size
    );
  
  sig = new float[N];
  ///print the signal samples
  //System.out.printf("***********The Signal %d samples, fundamental %1.2f Hz harmonic %1.2f Hz***************\n\n",N,f2,f1);
  for(int tl=0;tl<samples.length;tl++) {
    // System.out.printf("%1.4f ",samples[tl]);
     sig[tl] = samples[tl];
  }


//initialize output arrays
  for (int i=0; i<N; i++) {
    tcfslice[i]=0.0;
    for (int j=0; j<N; j++) {
      tcf[i][j]=0.0;   
      tfr[i][j]=0.0;
    }
  }

//call the fft constructor
//fft.specsize is typically equal to timeSize()/2 + 1
//access is only provided to frequency bands with indices less than half the length, 
//because they correspond to frequencies below the Nyquist frequency
//for FFT with a timeSize of 1024 and SR=44100
//for band/bin 5 you calculate 5/1024 * 44100 = 0.0048828125 * 44100 = 215 Hz
//we have 
fft = new FFT(N, N);

//create the FFT window as hamming 
  float[] win = new float[N-1]; //make the window odd length
  float pi = (float)Math.PI;
  float r;
  int m = (N-1) / 2;
  r = pi / m;
  for (int w= -m; w <= m; w++){
    win[m + w] = 0.54f + 0.46f * (float)Math.cos(w * r);
    if((N-1)%2==1){
       win[(N-1)-1]=win[0];  //if odd length signal set first and last samples equal
    }
  }
                       
  //create the same parameters used in Matlab code
 hlength=win.length+1-(win.length%2);
 Lh=(hlength-1)/2;

 
 for (int icol=1; icol<=samples.length; icol++) {  //for all time
    int [] k=  {icol-1, N-icol, round(N/2)-1, Lh};  
    taumax=getMin(k); //calculate taumax which will be used in tcf
    if (taumax==0) {
        tcf[(N+taumax)%N][icol-1]=win[Lh+1+taumax-1]*samples[icol+taumax-1]*samples[icol-taumax-1];
 
    } else {            

      for (int tm=1; tm<=taumax; tm++) {
        tcf[(N+tm)%N][icol-1]=win[Lh+1+tm-1]*samples[icol+tm-1]*samples[icol-tm-1];
      }
      
       for (int i = 0; i < N; ++i) {
      tcfslice[i]=tcf[i][icol-1];
    }

      fft.forward(tcfslice);
      specslice = fft.getSpectrumReal();
      for (int i = 0; i < N; ++i)
          tfr[i][icol] = specslice[i];
    }
  }
//println("********fund: *******",(f1/N)*(float)44100);
}


float cameraStep = 100;
// our current z position for the camera
float cameraPos = 0;
// how far apart the spectra are so we can loop the camera back
float spectraSpacing = 5;

float dt;
void mousePressed() {
  dt =.008;
}

void mouseClicked() {
  dt=0;
}


void mouseReleased() {
  dt = 1.0/50;
}

void draw()
{
  
  background(0);

//the following is based on the onlineAnalysis.pde code from the Minim examples
  cameraPos += cameraStep * dt;
  //println("campos: ",cameraPos);

  // jump back to start position when we get to the end
  if ( cameraPos > spectra.length * spectraSpacing )
  {
    cameraPos = 0;
  }


  float camNear = cameraPos - 200;  //this was 20
  float camFar  = cameraPos + 500;
  float camFadeStart = lerp(camNear, camFar, 0.4f);

  // render the spectra going back into the screen
 // println();
  //for all frequency points
  for (int s = 0; s < spectra.length; s++)  //0 to N
  {
    float z = s * spectraSpacing;
    //z is the separation of each frequency line
    // don't draw spectra that are behind the camera or too far away
    if ( z > camNear && z < camFar )
    {
      float fade = z < camFadeStart ? 1 : map(z, camFadeStart, camFar, 1, 0);
   //   
       if (s==spectra.length-1) {
         strokeWeight(3);
        stroke(255, 0, 0);
       }
      else if (s%(2*f1)==0)   {//for fundamental f1=16, appears in WD at tau=f1*2 = 32 
                           //position s=0 if 0 frequency slice
                           // f2=32 will appear at slice 63
                           // we color every multiple of 32 for convenience of tracking
         strokeWeight(2);
        stroke(255, 255, 0); 
      } else{
        strokeWeight(1);
        stroke(255*fade);  //from original offlineAnalyisi code
      }
      for (int i = 0; i < tfr[s].length-1; ++i )
      {
        //line(-256 + i, tfr[s][i]*25, z, -256 + i + 1, tfr[s][i+1]*25, z);
        line(-N + 2*i, tfr[s][i]*15, z, -N + 2*i + 1, tfr[s][i+1]*15, z);
      }
    }
  }

  //  camera( 200, 200, -200 + cameraPos, 75, 50, cameraPos, 0, -1, 0 );
  
  
  //use the camera function from Processing to place the spwd at a particular x,y,z configuration
  //camera(  eyeX,    eyeY,      eyeZ,         ctrX,ctrY,ctrZ,   upX,upY,upZ);
  //eyeZ axis moves with the cameraPos parameter as well as the center point of z axis
  camera( width/3,height/6, -100 + cameraPos, 75, 50, cameraPos, 0, -1, 0 );
  
  //allow the mouse to move the spwd on the screen
  //camera( mouseX,mouseY, -100 + cameraPos, 75, 50, cameraPos, 0, -1, 0 );
  
  //default setting from processing reference
  //camera(width/2,height/2,(height/2.0) / tan(PI*30.0 / 180.0) + cameraPos,width/2.0, height/2.0, cameraPos, 0, -1, 0);
}


// Method for getting the minimum value
public static int getMin(int[] inputArray) { 
  int minValue = inputArray[0]; 
  for (int i=1; i<inputArray.length; i++) { 
    if (inputArray[i] < minValue) { 
      minValue = inputArray[i];
    }
  } 
  return minValue;
} 
