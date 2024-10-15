#!/usr/bin/env python
# coding: utf-8

# In[1]:


### Author: Gerald Campos
### Email: geraldcamposm10@gmail.com
### Github: @gejocamo10
### WARNING: The material embodied in this software is provided to you "as-is" 
###          and without warranty of any kind, express, implied or otherwise, 
###          including without limitation, any warranty of fitness for a particular purpose. 
###          The author WILL NOT take any responsability of potential errors in the uses of this software.
###          The following software must be used responsibly.

import sys
import numpy as np
import pandas as pd
from math import ceil
from statistics import NormalDist

# Algorithm from Table 3.1., page 103, Stefanica, 2nd Ed. (useful more for HW4 and HW5 questions)
def Stefanica_Normal_CDF(t):    
    z = abs(t)
    y = 1/(1 + (0.2316419 * z))
    a1 = 0.319381530
    a2 = -0.356563782
    a3 = 1.781477937
    a4 = -1.821255978
    a5 = 1.330274429
    m = 1 - (np.exp(-(t**2)/2) * ((a1 * y) + (a2 * y**2) + (a3 * y**3) + (a4 * y**4) + (a5 * y**5))/np.sqrt(2*np.pi))
    if t > 0: return m
    else: return 1 - m
    
# Simpson Integration (recall from HW2 notebook)
def SimpsonRule(a, b, n, function):
    """
    Simpson's Rule according Dan Stefanica's textbook 
    'A primer for mathematics of Financial Engineering' (1st Edition).
    Chapter 2. Page 53-55.
    """
    h = (b-a)/n
    nRange = range(n+1)
    ai = [a + (i * h) for i in nRange]
    xi = [(ai[idx-1] + ai[idx])/2 for idx in nRange[1:]]
    fai = [function(a_i) for a_i in ai[1:-1]]
    fxi = [function(x_i) for x_i in xi]
    stefanicaSimp =     h *( (function(ai[0]) + function(ai[n]))/6 + 1/3*(sum(fai)) + 2/3*(sum(fxi)) ) 
    return stefanicaSimp

def evaNumericalIntegration(a, b, n, function, tolerance = 10**-12, digits=12):
    dictIntegration = {}
    dictIntegration[str(n)] = SimpsonRule(a, b, n, function)
    while True:
        n_ = n*2
        dictIntegration[str(n_)] = SimpsonRule(a, b, n_, function)
        if abs(dictIntegration[str(n)] - dictIntegration[str(n_)]) < tolerance:
            break
        n = n_
    return dict([a, str(round(x, digits))] for a, x in dictIntegration.items())

# general PDF integral
def NormalPDF(x):
    return (1/np.sqrt(2 * np.pi)) * np.exp(-(x**2)/2)

############################################# BLACK SCHOLES CLASS #################################################
### Seee HW3Q14 to check that this class works well
class ComputeOptionBSE(object):
    """
    Class of the BSE Framework to price Call/Put European Vanilla Options
    """
    def __init__(self, S, sigma, r, q):
        self.S = S
        self.sigma = sigma
        self.r = r
        self.q = q
        
    def __ComputeD1__(self, deltaT, K, returnVal=False):
        logSK = np.log(self.S / K)
        self.d1 =         (logSK+(self.r - self.q + (self.sigma**2)/2)*deltaT)/(self.sigma*np.sqrt(deltaT))
        if returnVal:
            return self.d1
        
    def __ComputeD2__(self, deltaT, K, returnVal=False):
        self.d2 = self.d1 - (self.sigma*np.sqrt(deltaT))
        if returnVal:
            return self.d2
        
    def __GetN__(self, dvalue, method = "standard"):
        if method == 'standard':
            return NormalDist().cdf(dvalue)
        elif method == 'stefanica':
            return Stefanica_Normal_CDF(dvalue)
        elif method == 'simpson':
            # please, if you want to modify the params for the simpsons computation, do it here!
            baseLimit, partitions, tolerance, digits = 0, 4, 10**-12, 18
            # if dvalue is negative
            if dvalue < 0:
                dPositiveValue = -1 * dvalue
                simpson_dpositive_approx = evaNumericalIntegration(
                    baseLimit, dPositiveValue, partitions, NormalPDF, tolerance, digits=digits
                )
                N_dpositiveValue =                 float(list(simpson_dpositive_approx.values())[-1]) + Stefanica_Normal_CDF(baseLimit)
                return 1 - (N_dpositiveValue)
            # if dvalue is positive
            else:
                simpson_dpositive_approx = evaNumericalIntegration(
                    baseLimit, dvalue, partitions, NormalPDF, tolerance, digits=digits
                )
                N_dpositiveValue =                 float(list(simpson_dpositive_approx.values())[-1]) + Stefanica_Normal_CDF(baseLimit)               
                return N_dpositiveValue
            
        
    def PutOption(self, deltaT, K, returnDelta = False, quantityFactor = 1000, cdf_method = 'standard'):
        self.__ComputeD1__(deltaT, K)
        self.__ComputeD2__(deltaT, K)
        
        minusNd1, minusNd2 = self.__GetN__(-self.d1, cdf_method), self.__GetN__(-self.d2, cdf_method)
        deltaPut = -quantityFactor * np.exp(-self.q * deltaT) * minusNd1
        
        putValue =         (K * np.exp(-self.r * deltaT) * minusNd2) -         (self.S * np.exp(-self.q * deltaT) * minusNd1)
        
        if returnDelta: 
            return putValue, deltaPut
        else:
            return putValue
        
    def CallOption(self, deltaT, K, returnDelta = False, quantityFactor = 1000, cdf_method = 'standard'):
        self.__ComputeD1__(deltaT, K)
        self.__ComputeD2__(deltaT, K)
        
        Nd1, Nd2 =  self.__GetN__(self.d1, cdf_method), self.__GetN__(self.d2, cdf_method)
        deltaCall = quantityFactor * np.exp(-self.q * deltaT)* Nd1        

        callValue =         (self.S * np.exp(-self.q * deltaT) * Nd1) -         (K * np.exp(-self.r * deltaT) * Nd2)
        
        if returnDelta: 
            return callValue, deltaCall
        else:
            return callValue
        
    def get(self, deltaT, K, option_type, returnDelta = False, quantityFactor = 1000, cdf_method = 'standard'):
        if option_type.lower() == 'call':
            return         self.CallOption(deltaT = deltaT, K=K, returnDelta = returnDelta, quantityFactor = quantityFactor, cdf_method = cdf_method)
        elif option_type.lower() == 'put':
            return         self.PutOption(deltaT = deltaT, K=K, returnDelta = returnDelta, quantityFactor = quantityFactor, cdf_method = cdf_method)
        else:
            sys.exit(f"Error Arised! >> Not recognized 'option_type': {option_type}. Please, double check.")

            
class BSE_EmbeddedFramework(object):
    def __init__(self, K, deltaT, PVF, disc):
        self.K = K
        self.PVF = PVF
        self.disc = disc
        self.deltaT = deltaT
        
    def __ComputeDi__(self, sigma):
        # term 1 of d1 and d2
        term1 =         np.log(self.PVF/(self.K * self.disc))/(sigma * np.sqrt(self.deltaT))
        # term 2 of d1 and d2
        term2 = (sigma * np.sqrt(self.deltaT)) / 2
        # d1
        self.d1 = term1 + term2 
        # d2
        self.d2 = term1 - term2
        
    def __GetN__(self, dvalue, method = "standard"):
        # only standard and stefanica method's for this particular class
        if method == 'standard':
            return NormalDist().cdf(dvalue)
        elif method == 'stefanica':
            return Stefanica_Normal_CDF(dvalue)
        else:
            sys.exit("Only 'standard' and 'stefanica' for Standard Normal CDF!")
            
    def VegaOption(self, sigma, cdf_method = "standard"):
        # compute d1 and d2 | only d1 matters
        self.__ComputeDi__(sigma)
        # compute vega | same for call and put
        vega = self.PVF * np.sqrt(self.deltaT/(2*np.pi)) * np.exp(-((self.d1**2)/2))
        return vega
    
    def PutOption(self, sigma, cdf_method = "standard"):
        # compute d1 and d2
        self.__ComputeDi__(sigma)
        # compute N(-d1) and N(-d2)
        minusND1, minusND2 = self.__GetN__(-self.d1, cdf_method), self.__GetN__(-self.d2, cdf_method)
        # compute put value | 'Pm': market price of the put option
        putValue = (self.K * self.disc * minusND2) - (self.PVF * minusND1)
        # return final put value
        return putValue
    
    def CallOption(self, sigma, cdf_method = "standard"):
        # compute d1 and d2
        self.__ComputeDi__(sigma)
        # compute N(d1) and N(d2)
        ND1, ND2 = self.__GetN__(self.d1, cdf_method), self.__GetN__(self.d2, cdf_method)
        # compute call value | 'Cm': market price of the call option
        callValue = (self.PVF*ND1) - (self.K * self.disc * ND2)
        # return final call value
        return callValue  


# In[ ]:




