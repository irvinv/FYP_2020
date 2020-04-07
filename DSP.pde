/*
 *  Copyright 2006 Columbia University.
 *
 *  This file is part of MEAPsoft.
 *
 *  MEAPsoft is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2 as
 *  published by the Free Software Foundation.
 *
 *  MEAPsoft is distributed in the hope that it will be useful, but
 *  WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with MEAPsoft; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 *  02110-1301 USA
 *
 *  See the file "COPYING" for the text of the license.
 */

//package com.meapsoft;

import java.util.Arrays;
import java.io.*;
import javax.sound.sampled.*;
//import com.meapsoft.gui.DataDisplayPanel;

/*
 * Library of basic DSP algorithms.  Most of these have analogs in
 * Matlab with the same name.  
 *
 * This code only operates on real valued data.
 *
 * @author Ron Weiss (ronw@ee.columbia.edu)
 */
public class DSP
{
    /**
     * Convolves sequences a and b.  The resulting convolution has
     * length a.length+b.length-1.
     */
     
     public DSP() {
     }
    public float[] conv(float[] a, float[] b)
    {
        float[] y = new float[a.length+b.length-1];

        // make sure that a is the shorter sequence
        if(a.length > b.length)
        {
            float[] tmp = a;
            a = b;
            b = tmp;
        }

        for(int lag = 0; lag < y.length; lag++)
        {
            y[lag] = 0;

            // where do the two signals overlap?
            int start = 0;
            // we can't go past the left end of (time reversed) a
            if(lag > a.length-1) 
                start = lag-a.length+1;

            int end = lag;
            // we can't go past the right end of b
            if(end > b.length-1)
                end = b.length-1;

            //System.out.println("lag = " + lag +": "+ start+" to " + end);
            for(int n = start; n <= end; n++)
            {
                //System.out.println("  ai = " + (lag-n) + ", bi = " + n); 
                y[lag] += b[n]*a[lag-n];
            }
        }

        return(y);
    }

    /**
     * Computes the cross correlation between sequences a and b.
     */
    public float[] xcorr(float[] a, float[] b)
    {
        int len = a.length;
        if(b.length > a.length)
            len = b.length;

        return xcorr(a, b, len-1);

        // // reverse b in time
        // float[] brev = new float[b.length];
        // for(int x = 0; x < b.length; x++)
        //     brev[x] = b[b.length-x-1];
        // 
        // return conv(a, brev);
    }

    /**
     * Computes the auto correlation of a.
     */
    public float[] xcorr(float[] a)
    {
        return xcorr(a, a);
    }

    /**
     * Computes the cross correlation between sequences a and b.
     * maxlag is the maximum lag to
     */
    public float[] xcorr(float[] a, float[] b, int maxlag)
    {
        float[] y = new float[2*maxlag+1];
        Arrays.fill(y, 0);
        
        for(int lag = b.length-1, idx = maxlag-b.length+1; 
            lag > -a.length; lag--, idx++)
        {
            if(idx < 0)
                continue;
            
            if(idx >= y.length)
                break;

            // where do the two signals overlap?
            int start = 0;
            // we can't start past the left end of b
            if(lag < 0) 
            {
                //System.out.println("b");
                start = -lag;
            }

            int end = a.length-1;
            // we can't go past the right end of b
            if(end > b.length-lag-1)
            {
                end = b.length-lag-1;
                //System.out.println("a "+end);
            }

            //System.out.println("lag = " + lag +": "+ start+" to " + end+"   idx = "+idx);
            for(int n = start; n <= end; n++)
            {
                //System.out.println("  bi = " + (lag+n) + ", ai = " + n); 
                y[idx] += a[n]*b[lag+n];
            }
            //System.out.println(y[idx]);
        }

        return(y);
    }

//    /**
//     * Returns the elementwise sum of a and b.  a and b should be
//     * the same length or bad things will happen.
//     */
    public float[] plus(float[] a, float[] b)
    {
        float[] y = new float[a.length];

        for(int x = 0; x < y.length; x++)
            y[x] = a[x]+b[x];

        return y;
    }

//    /**
//     * Returns the sum of the contents of a.
//     */
    public  float sum(float[] a)
    {        
        float y = 0;

        for(int x = 0; x < a.length; x++)
            y += a[x];

        return y;
    }

//    /**
//     * Returns the max element of a.
//     */
    public  float max(float[] a)
    {        
        float y = Float.MIN_VALUE;

        for(int x = 0; x < a.length; x++)
            if(a[x] > y)
                y = a[x];

        return y;
    }

//    /**
//     * Returns the absolute value of each element of a.
//     */
    public  float[] abs(float[] a)
    {        
        float[] y = new float[a.length];

        for(int x = 0; x < y.length; x++)
            y[x] = Math.abs(a[x]);

        return y;
    }

}
