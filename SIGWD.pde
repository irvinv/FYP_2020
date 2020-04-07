public class SIGWD {
  float[] samples, samples1,samples2;
  
  float waveFrequency,waveFrequency1;
  float waveSampleRate;

  // generate the sample by using Waves.SINE
  float lookUp,lookUp1; 
  float lookUpStep,lookUpStep1;
  
  public SIGWD(int N) {
    samples = new float[N];
    samples1 = new float[N];
    samples2 = new float[N];
    waveFrequency  = f1;
    waveFrequency1  = f2;
    waveSampleRate = (float)N;
    lookUp = 0;
    lookUp1 = 0;
    lookUpStep = waveFrequency / waveSampleRate;
    lookUpStep1 = waveFrequency1 / waveSampleRate;
  }
    

  public float[] compSig() {
    for ( int i = 0; i < samples.length; ++i ) {
    samples[i] = Waves.SINE.value(lookUp);  
    lookUp = (lookUp + lookUpStep) % 1.0f;
     }
     
    for ( int i = 0; i < samples1.length; ++i ) {
    samples1[i] = Waves.SINE.value(lookUp1);  
    lookUp1 = (lookUp1 + lookUpStep1) % 1.0f;
     } 
     
     for ( int i = 0; i < samples1.length; ++i ) {
       samples2[i] = (samples[i]+samples1[i])/2.0f;
     } 
     return samples2;
  }
    
  }
  
  
  
