#!/usr/bin/env python
# coding: utf-8

# In[ ]:


### Author: Gerald Joel Campos Morey
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

import math
import sympy
from sympy.abc import x as _x_
from ACFEBlackScholesFramework import ComputeOptionBSE, evaNumericalIntegration, BSE_EmbeddedFramework

# define universal basis points
oneBps = 0.0001

########################### 1. Newton Method - BSE Framework
def NewtonBSE(Vprice, S, K, dT, q, r, x0, option_type, 
              tol=10**-6, method_cdf='simpson', printx=True):
    """
    Newton-Raphson method to estimate the implied volatility of a vanilla european option.
    
    Based on Pseudocode of Table 5.7. Dr. Stefanica, Chap. 5. page 152. 2nd Ed.
    """
    # def of initial guesses
    xnew, xold = x0, x0 - 1
    # def initial counter
    counter = 0
    # while loop initialization with condition
    while abs(xnew - xold) > tol: 
        # definition of black scholes framework based on xnew
        bse_frame_xnew = ComputeOptionBSE(S = S, sigma = xnew, r = r, q = q)
        # computation of d1 based on current xnew
        d1_xnew = bse_frame_xnew.__ComputeD1__(deltaT = dT, K = K, returnVal=True)
        # computation of vega based on current d1
        vega_xnew = (1/np.sqrt(2*np.pi)) * S * np.exp(-q * dT) * np.sqrt(dT) * np.exp(-np.power(d1_xnew, 2)/2)
        # check if option is call, put or not recognized type
        if option_type.lower() == 'call':
            fBs_new = bse_frame_xnew.CallOption(deltaT= dT, K = K, cdf_method=method_cdf)
        elif option_type.lower() == 'put':
            fBs_new = bse_frame_xnew.PutOption(deltaT= dT, K = K, cdf_method=method_cdf)
        else:
            print(f"Error! >>>> not recognized option type {option_type}")
            break
        # saving the current xnew now as xold
        xold = xnew
        # computing new version of xnew from Newton-Raphson formulae
        xnew= xnew - ((fBs_new - Vprice)/vega_xnew)
        # adding value to the counter
        counter +=1
        # print process if required
        if printx: print(f"X{counter} : {xnew}")
    # return final current value of 
    return xnew

############## Newton's method for emb. volatility
def NewtonBSE_EmbVolatility(Vprice, K, dT, PVF, disc, 
                           option_type, x0 = 0.25, tol=10**-6, method_cdf='simpson', printx=True):
    xnew, xold = x0, x0 - 1
    
    counter = 0 
    
    # definition of black scholes framework for embb volatiliy | non-iterable 
    bse_frame = BSE_EmbeddedFramework(K = K, deltaT = dT, PVF = PVF, disc = disc)    
    
    # while loop initialization with condition
    while abs(xnew - xold) > tol: 
        # computation of vega based on current xnew (i.e., in new implied vol)
        vega_xnew = bse_frame.VegaOption(sigma = xnew, cdf_method = method_cdf)
        # check if option is call, put or not recognized type
        if option_type.lower() == 'put':
            fBs_new = bse_frame.PutOption(sigma = xnew, cdf_method=method_cdf)
        elif option_type.lower() == 'call':
            fBs_new = bse_frame.CallOption(sigma = xnew, cdf_method=method_cdf)
        else:
            print(f"Error! >>>> not recognized option type {option_type}")
            break
        # saving the current xnew now as xold
        xold = xnew
        # computing new version of xnew from Newton-Raphson formulae
        xnew= xnew - ((fBs_new - Vprice)/vega_xnew)
        # adding value to the counter
        counter +=1        
        # print process if required
        if printx: print(f"X{counter} : {xnew}")      
    # return final current value of 
    return xnew  

########################### 2. Bisection Method - BSE Framework
def BisectionBSE(Vprice, S, K, dT, q, r, xa, xb, option_type, 
                 tolinit=10**-6, tolapprox=10**-9, method_cdf='simpson', printx=True):
    """
    Bisection method to estimate the implied volatility of a vanilla european option.
    
    Based on Pseudocode of Table 5.1. Dr. Stefanica, Chap. 5. page 136. 2nd Ed.
    """
    # def of initial guesses
    xL, xR = xa, xb
    # def initial counter
    counter = 0    
    # definition of fxL
    fxL = ComputeOptionBSE(
        S = S, sigma = xL, r = r, q = q
    ).get(deltaT= dT, K = K, option_type=option_type, cdf_method=method_cdf) -  Vprice
    # definition of fxR
    fxR = ComputeOptionBSE(
        S = S, sigma = xR, r = r, q = q
    ).get(deltaT= dT, K = K, option_type=option_type, cdf_method=method_cdf) - Vprice  
    
    # while loop initialization with conditions
    while (max(abs(fxL),abs(fxR)) > tolapprox) or (xR - xL > tolinit):
        # compute intermediate value xM
        xM = (xL + xR)/2
        # compute fxM
        fxM = ComputeOptionBSE(
            S = S, sigma = xM, r = r, q = q
        ).get(deltaT= dT, K = K, option_type=option_type, cdf_method=method_cdf) - Vprice        
        
        # check if fxM and fxL have different signs, or not
        if (fxM * fxL) < 0:
            # reduce interval from the right, such as the new active interval [xL, xM]
            xR = xM 
            # compute the new fxR since now xR = xM
            fxR = ComputeOptionBSE(
                S = S, sigma = xR, r = r, q = q
            ).get(deltaT= dT, K = K, option_type=option_type, cdf_method=method_cdf) - Vprice  
        else:
            # reduce interval from the left, such as the new active interval [xM, xR]
            xL = xM 
            # compute the new fxL since now xL = xM
            fxL = ComputeOptionBSE(
                S = S, sigma = xL, r = r, q = q
            ).get(deltaT= dT, K = K, option_type=option_type, cdf_method=method_cdf) - Vprice              
        
        # adding value to the counter
        counter +=1
        # print process if required
        if printx: print(f"Iteration {counter} : ({xR}, {xL})")
    return xR, xL

########################### 3. Secant Method - BSE Framework
def SecantBSE(Vprice, S, K, dT, q, r, x0, x_1, option_type, 
              tolconsec=10**-6, tolapprox=10**-9, method_cdf='simpson', printx=True):
    
    # definition of xnew and xold
    xnew, xold = x0, x_1
    # def initial counter
    counter = 0    
    # definition of fxNew
    fxNew = ComputeOptionBSE(
        S = S, sigma = xnew, r = r, q = q
    ).get(deltaT= dT, K = K, option_type=option_type, cdf_method=method_cdf) - Vprice    
    
    # while loop initialization with conditions
    while (abs(fxNew) > tolapprox) or (abs(xnew - xold) > tolconsec):
        xoldest = xold
        xold = xnew

        # definition of fxOld
        fxOld = ComputeOptionBSE(
            S = S, sigma = xold, r = r, q = q
        ).get(deltaT= dT, K = K, option_type=option_type, cdf_method=method_cdf) - Vprice    
        
        # definition of fxOldest
        fxOldest = ComputeOptionBSE(
            S = S, sigma = xoldest, r = r, q = q
        ).get(deltaT= dT, K = K, option_type=option_type, cdf_method=method_cdf) - Vprice            
        
        # compute new value for xnew
        xnew = xold - (fxOld * (xold - xoldest)/(fxOld - fxOldest) )
        
        # updated computation of fxNew considering the new value for xnew
        fxNew = ComputeOptionBSE(
            S = S, sigma = xnew, r = r, q = q
        ).get(deltaT= dT, K = K, option_type=option_type, cdf_method=method_cdf) - Vprice    
        
        # adding value to the counter
        counter +=1
        # print process if required
        if printx: print(f"Iteration {counter} | Xnew : {xnew}")        
        
    return xnew

########################### 4. Newton Method - Yield for a bond
def bond_formula(t_cash_flows, v_cash_flows, y):
    """
    General Function to compute Bond Formulae for a given 'y' interest rate.
    
    Input:
        - 'v_cash_flows': list containing cashflows (coupon payment and face value) 
        - 't_cash_flows': list containing timeframework of each cashflow
    Output:
        - bond price
    """
    
    # computing the discount factors (since 'period' is in annual terms)
    disc_factors = [np.exp(-y * period) for period in t_cash_flows]
    # return bond's price
    return sum(np.array(disc_factors) * np.array(v_cash_flows))

def bond_derivative_formula(t_cash_flows, v_cash_flows, y):
    # computing the derivate discount factors (since 'period' is in annual terms)
    derivative_disc_factors = [period*np.exp(-y * period) for period in t_cash_flows]
    # return bond's derivate price w.r.t. 'y'
    return -sum(np.array(derivative_disc_factors) * np.array(v_cash_flows))

def bond_second_derivative_formula(t_cash_flows, v_cash_flows, y):
    # computing the derivate discount factors (since 'period' is in annual terms)
    second_derivative_disc_factors = [np.power(period,2)*np.exp(-y * period) for period in t_cash_flows]
    # return bond's 2nd derivate price w.r.t. 'y'
    return sum(np.array(second_derivative_disc_factors) * np.array(v_cash_flows))

def NewtonYieldBond(Bprice, t_cash_flows, x0, v_cash_flows, tolerance=10**-6, printx=True):
    """
    Newton-Raphson method to estimate the yield of a bond.
    
    Based on Pseudocode of Table 5.6. Dr. Stefanica, Chap. 5. page 150. 2nd Ed.
    """    
    
    # def initial counter
    counter = 0     
    
    # def of initial guesses
    xnew, xold = x0, x0 - 1
    
    # def number of cash flows
    assert len(t_cash_flows) == len(v_cash_flows),     "Number of time cashflows is different from total cashflows"
    
    # loop initialization with condition
    while abs(xnew - xold) > tolerance:
        # updating in advance xold by the current xnew 
        xold = xnew

        # defining fB and dB functions
        fBy = bond_formula(t_cash_flows, v_cash_flows, y=xold) - Bprice
        dBy = bond_derivative_formula(t_cash_flows, v_cash_flows, y=xold)
        
        # computing Newton's Method (here is a negative '-' since dBy < 0 from its func. definition)
        xnew = xold - (fBy / dBy)
        
        # adding value to the counter
        counter +=1
        # print process if required
        if printx: print(f"X{counter} : {xnew}")
    return xnew

########################### 4.1. Extra Computation: Bond Stefanica Method given the yield
def stefanicaBond(t_cashflows, v_cashflows, yieldB):
    """
    Base Dr. Stefanica's Computation to find Price, Duration and Convx. of a bond
    given the yield.
    
    Table 2.7., page 69, 2nd Ed.
    
    Important: USE THIS METHOD WHEN ARE APPLYING TAYLOR FORMULAE BOND PRICE APPROX
    """
    n = len(v_cashflows)
    
    B, D, C = 0, 0, 0
    
    for idx in range(n):
        disc = np.exp(-t_cashflows[idx] * yieldB)
        B = B + (v_cashflows[idx] * disc)
        D = D + (t_cashflows[idx] * v_cashflows[idx] * disc)
        C = C + ((t_cashflows[idx]**2) * v_cashflows[idx] * disc)
        
    # return bond price, duration and convexity
    return B, D/B, C/B

########################### 5. Newton Method - Delta of a Call as a function
def NewtonMethodDelta(deltaValue, x0, S, dT, q, r, sigma, tolconsec=10**-6, method_cdf='simpson', printx=True):
    """
    Newton-Raphson method to solve a question for a delta of a call as a general function, given K.
    
    Useful for Q4. Part II.
    
    Based on Pseudocode of Table 5.2. Dr. Stefanica, Chap. 5. page 139. 2nd Ed.
    """    
    # def initial counter
    counter = 0
    
    # define initial guesses
    xnew, xold =x0, x0 - 1
    
    # define base general balck scholes framework (here these work as parameters, not variables)
    bseframe = ComputeOptionBSE(S = S, sigma = sigma, r = r, q = q)
    
    # compute 1st fxnew before iterative process (notice that fx = delta(Cx))
    fxnew = bseframe.CallOption(
        deltaT= dT, 
        K = xnew, 
        returnDelta = True, 
        quantityFactor = 1, 
        cdf_method=method_cdf
    )[1] - deltaValue
    
    # starting loop process with conditions
    while (abs(xnew - xold) > tolconsec): # (abs(fxnew)> tolapprox) or 
        # save the current xnew as the new xold
        xold = xnew 
        
        # compute fxold (notice that fx = delta(Cx))
        fxold = bseframe.CallOption(
            deltaT= dT, 
            K = xold, 
            returnDelta = True, 
            quantityFactor = 1, 
            cdf_method=method_cdf
        )[1] - deltaValue
        
        # compute d1 from xold
        d1_xold = bseframe.__ComputeD1__(deltaT= dT, K=xold, returnVal=True)
        
        # compute f'xold
        dfxold = -(np.exp(-q * dT)/(xold * sigma * np.sqrt(dT))) * (np.exp(-(d1_xold**2)/2)/ np.sqrt(2 * np.pi))
        
        # update the xnew value given formulae en part(i)
        xnew = xold - (fxold/dfxold)
        
        # adding value to the counter
        counter +=1
        # print process if required
        if printx: print(f"X{counter} : {xnew}")        
    return xnew    


########################### 6. Tetha for a Put
def theta_put(S, K, dT, q, r, sigma, method_cdf='simpson'):
    """
    General Function to find the theta for a put.
    """
    
    # define bse framework 
    bseframe = ComputeOptionBSE(S = S, sigma = sigma, r = r, q = q)
    # compute d1
    d1 = bseframe.__ComputeD1__(deltaT=dT, K=K, returnVal=True)
    # compute d2
    d2 = bseframe.__ComputeD2__(deltaT=dT, K=K, returnVal=True)
    # get N(-d1)
    minus_Nd1 = bseframe.__GetN__(-d1, method = method_cdf)
    # get N(-d2)
    minus_Nd2 = bseframe.__GetN__(-d2, method = method_cdf)
    
    # find first term of tetha
    firstTerm = -np.divide(S * sigma * np.exp(-q * dT), 2 * np.sqrt(2 * np.pi * dT)) * np.exp(-(d1**2)/2)
    # find second term of tetha
    secondTerm = -q * S * np.exp(-q * dT) * minus_Nd1
    # find third term of tetha
    thirdTerm = r * K * np.exp(-r * dT) * minus_Nd2
    
    # return tetha
    return firstTerm + secondTerm + thirdTerm

def derivative_theta(x0, K, dT, q, r, sigma, method_cdf='simpson'):
    """
    Method that compute the derivative of a theta.
    
    Notice that:
        x0 = S / K
    """
    # define S in terms of X0
    Sx0 = x0 * K
    
    # define bse framework 
    bseframe = ComputeOptionBSE(S = Sx0, sigma = sigma, r = r, q = q)
    
    # compute d1 of x0
    d1x0 = bseframe.__ComputeD1__(deltaT=dT, K=K, returnVal=True)    
    
    # compute d2 of x0
    d2x0 = bseframe.__ComputeD2__(deltaT=dT, K=K, returnVal=True)
    
    # get N(-d1) over x0
    minus_Nd1x0 = bseframe.__GetN__(-d1x0, method = method_cdf)    
    
    # first term of derivative of theta
    first_term =     (sigma * K * np.exp(-q * dT)) / (2 * np.sqrt(2 * np.pi * dT)) * np.exp(-(d1x0**2)/2) * (d1x0/(sigma * np.sqrt(dT)) - 1)
    # 2nd term of derivative of theta
    second_term =     -q * K * np.exp(-q * dT) * ( minus_Nd1x0 - np.exp(-(d1x0**2)/2)/(sigma * np.sqrt(2 * np.pi * dT)) ) 
    # third term of derivative of theta
    third_term =     -r * K * np.exp(-r * dT) * np.exp(-(d2x0**2)/2) / (sigma * x0 * np.sqrt(2 * np.pi * dT))
    
    # return derivative of theta
    return first_term + second_term + third_term

def NewtonThetaPut(x0, K, dT, q, r, sigma, method_cdf='simpson', tolerance=10**-6, tolapprox=10**-9, printx=True): 

    """
    Newton-Raphson method to estimate the yield of a bond.
    
    Based on Pseudocode of Table 5.6. Dr. Stefanica, Chap. 5. page 150. 2nd Ed.
    """    
    
    # def initial counter
    counter = 0     
    
    # def of initial guesses
    xnew, xold = x0, x0 - 1
    
    # compute first theta x0 to start the process
    thetaPutxnew = theta_put(S = xnew * K, K = K, dT = dT, q = q, r = r, sigma = sigma, method_cdf=method_cdf)    
    
    # loop initialization with condition
    while (abs(thetaPutxnew)>tolapprox) or (abs(xnew - xold) > tolerance):
        # updating in advance xold by the current xnew 
        xold = xnew
        
        # computing theta of xold 
        thetaPutx0 = theta_put(S = xold * K, K = K, dT = dT, q = q, r = r, sigma = sigma, method_cdf=method_cdf)
        
        # computing derivative theta of xold
        dThetaPutx0 = derivative_theta(x0 = xold, K = K, dT=dT, q=q, r=r, sigma=sigma, method_cdf=method_cdf)
        
        # computing Newton's Method 
        xnew = xold - (thetaPutx0 / dThetaPutx0)
        
        # updating theta put based on xnew
        thetaPutxnew = theta_put(S = xnew * K, K = K, dT = dT, q = q, r = r, sigma = sigma, method_cdf=method_cdf)  
        
        # adding value to the counter
        counter +=1
        # print process if required
        if printx: print(f"X{counter} : {xnew}")
    return xnew


#################################################### 7. Bootstrapping using Newton's Method to find Zero Rate Curve
def StefanicaNewtonsMethod(x0, f, df, tol_consec=10**-6, tol_approx=10**-9, printx=False, return_counter=False):
    """
    Definition of stefanica's newton method.
    
    This is a standard formulation for any function 'f' defined using 'sympy' package.
    
    Based on Stefanica's formulation. Page 139. Chapter 5. 2nd Ed. ACFE.
    """
    xnew, xold = x0, x0-1
    
    counter = 0
    # empty list to save approx values over the iteration
    approx_values = []
    # base loop
    while  (abs(xnew - xold)>tol_consec):#(abs(f(xnew)) > tol_approx) or
        
        xold = xnew
        # newton's method
        xnew = xold - f(xold)/df(xold)
        
        counter+=1
        
        approx_values.append(xnew)
        
        # print process if required
        if printx: 
            print(f"X{counter} : {xnew}") 
    
    # return extra details if required
    if return_counter:
        return [xnew, counter, approx_values]
    # return normally
    else: 
        return [xnew]
    
def bootstrap_base(bond_timeframe, data, x0, 
                   face_value=100, tol_consec=10**-6, 
                   tol_approx=10**-9, overnight_rate = 0,
                   printx=False, counter_newton=False):
    """
    Base function that bootstrap the zero rate curve for a given dataset such as:
     	Maturity 	Coupon Rate 	Price
    0 	   0.5 	          0 	    97.5
    1 	   1.0 	          5 	    100.0
    2 	   3.0 	          5 	    102.0
    3 	   5.0 	          6 	    104.0
    
    When there are +2 unknowns at the first maturity datapoint (index 0), 
    an 'overnight_rate' parameter is required.
    """
    
    # maturities
    maturities = np.array(data["Maturity"])
    
    # coupons
    couponRates = np.array(data["Coupon Rate"])
    
    # bond prices
    prices = np.array(data["Price"])
    
    # get data time between payments as a factor w.r.t. bond payments framework 
    timePaymentsInterval = maturities / bond_timeframe
    
    # get coupon factors for each payment
    couponFactors = couponRates * bond_timeframe
    
    # define previous set of known zerorates timeframeworks
    known_zerorate_timeframeworks = []
    
    # zero_rates dictionary
    dict_zeroRates = {'0.0':overnight_rate}
    
    # dictionary to save extra details about newtons method for each maturity timeframe
    dict_extra_details = {}
    
    # time interval 
    for dataIdx, timeInterval in enumerate(timePaymentsInterval):

        # compute the time for each cashflow in a temporal list
        time_cashflows =         [maturities[dataIdx] - (t_factor*bond_timeframe) for t_factor in range(0, math.ceil(timeInterval))][::-1]
        
        # compute the quantity of each cashflow in a temporal list
        coupons_payments = [couponFactors[dataIdx]] * (len(time_cashflows)-1)
        coupons_payments.append(couponFactors[dataIdx] + face_value)

        # find unknown periods among each bond based on the time for cashflows w.r.t. previous one
        notKnownRates = list(set(time_cashflows) ^ set(known_zerorate_timeframeworks))
        notKnownRates.sort()

        if len(notKnownRates) > 1:
            
            # find the idx of the last known time index
            idx_lastknown = time_cashflows.index(notKnownRates[0]) - 1
            
            # if the index is positive, means there exist a previous known calculated zero rate
            if idx_lastknown > 0:   
                tk = time_cashflows[idx_lastknown]
            # otherwise, we should use the zero rate value
            else:
                tk = 0.0
            # find the longest unknown rate for its time cashflow
            tnu = notKnownRates[-1]

            # dictionary to save each r(0, t*) term with its coeff. 
            dictRatesTerms = {}

            # iterate over each unknown rate for its time cashflow
            for tiu in notKnownRates: 

                # compute weight for the unknown rate ('x')
                weight_unknownFactor = (tiu - tk)/(tnu - tk)
                # compute weight for the lastest known rate ("r(0, tk)")
                weight_knownFactor = (tnu - tiu)/(tnu - tk)
                # get the latest known rate
                known_rate = dict_zeroRates[str(tk)]
                # check if known rate doesn't have a sensible value
                if known_rate <= 0:
                    # is known rate for the overnight rate is zero or negative, redefine it
                    sys.exit(f">>> A positive rate for t = {tk} is needed, but it is {known_rate}. Redefine it.")
                # compute the definition formulae that defines the unknown rate
                formula_unknownRate =                 (weight_unknownFactor * _x_) + (weight_knownFactor * known_rate) 

                # update the zero rates dictionary with the formulae
                dict_zeroRates[str(tiu)] = formula_unknownRate          
                
                # update the coefficient for unknown and known rate respectively
                dictRatesTerms[str(tiu)] = [weight_unknownFactor, weight_knownFactor * known_rate]

                
            # compute the bond formulae terms in symbolic language considering 'x'
            bondFormulaeTerms =                 [
                    coupon * np.e**(-dt * dict_zeroRates[str(dt)]) 
                    for (dt, coupon) in zip(time_cashflows, coupons_payments)
                ]   
            
            # define base formula to apply Newton's method, such as f(x) = 0
            f = sum(bondFormulaeTerms) - prices[dataIdx]
            
            # define base differentiation of the formula to apply Newton's method
            diff_f = sympy.diff(f,_x_)

            # define object variables for the base function and its derivative
            f_func, diff_func =sympy.lambdify(_x_, f,'numpy'), sympy.lambdify(_x_, diff_f,'numpy')
            
            # compute Newton's Method and find x0; 
            # depending on bool 'return_counter', it returns [x0, num iterations, approx values]
            solutionLargestZeroRate = StefanicaNewtonsMethod(
                x0 = x0, 
                f = f_func, 
                df = diff_func, 
                tol_consec=tol_consec, 
                tol_approx=tol_approx, 
                printx=printx,
                return_counter=counter_newton
            )

            # save the new computed zero rate in the zero rates dictionary
            dict_zeroRates[str(notKnownRates[-1])] = solutionLargestZeroRate[0]
            dict_extra_details[str(notKnownRates[-1])] = solutionLargestZeroRate[1:]
            
            # iterate over each residual not known rate 
            for notKnownRate in notKnownRates[:-1]:
                # complete unknown factor for the intermediates/overnight rates
                solutionOvernightRate =                 (dictRatesTerms[str(notKnownRate)][0] * solutionLargestZeroRate[0]) +                dictRatesTerms[str(notKnownRate)][1]
                
                # save the solution in the general dictionary of zero rates
                dict_zeroRates[str(notKnownRate)] = solutionOvernightRate
            
        else:
            # define the not known rate as string with the unknown variable symbol ('x') as value
            dict_zeroRates[str(notKnownRates[0])] = _x_
            
            # compute the bond formulae terms in symbolic language considering 'x'
            bondFormulaeTerms =             [
                coupon * np.e**(-dt * dict_zeroRates[str(dt)]) 
                for (dt, coupon) in zip(time_cashflows, coupons_payments)
            ]
            
            # calculate the unknown zero rate ('new known zero rate')
            new_known_zeroRate = sympy.solve(sum(bondFormulaeTerms) - prices[dataIdx], "x")[0]
            
            # save the new computed zero rate in the zero rates dictionary
            dict_zeroRates[str(notKnownRates[0])] = new_known_zeroRate
            
        known_zerorate_timeframeworks = time_cashflows
        
    if counter_newton:
        return dict_zeroRates, dict_extra_details 
    else:
        return dict_zeroRates
    
    
######################################################### 8. Bond Price Adjustement for a change in the yield
def bondYieldAdj_NoConvex(priceBond, durationBond, changeYield):
    return priceBond * (1 - (durationBond * changeYield))

def bondYieldAdj_IncConvex(priceBond, durationBond, convexityBond, changeYield):
    return priceBond * (1 - (durationBond * changeYield) + ((convexityBond * (changeYield**2))/2) )


############################################################ Appendix | Final Exam Coding Sample


#################################### Problem Typo Q4 - Final Coding Sample Part
def derivative_normal(z):
    """
    Simple formulae that summarizes the derivative of a Standard Normal formulae.
    """
    return (1/np.sqrt(2*np.pi)) * np.exp(-(z**2)/2)

def derivativePutwrtK(S, K, sigma, r, q, dT, method_cdf='simpson'):
    """
    Derivative formulae of a put w.r.t. the strike price 'K'
    """
    bse_frame = ComputeOptionBSE(S = S, sigma = sigma, r = r, q = q)
    
    d1 = bse_frame.__ComputeD1__(deltaT = dT, K = K, returnVal=True)
    d2 = bse_frame.__ComputeD2__(deltaT = dT, K = K, returnVal=True)
    
    N_minus_d2 = bse_frame.__GetN__(dvalue = -d2, method = method_cdf)
    
    dN_d1 = derivative_normal(d1)
    dN_d2 = derivative_normal(d2)
    
    firstTerm = np.exp(-r * dT) * (N_minus_d2 + (K * dN_d2 * 1/(K * sigma * np.sqrt(dT))))
    secondTerm = S * np.exp(-q * dT) * dN_d1 * 1/(K * sigma * np.sqrt(dT))
    
    return firstTerm - secondTerm

def derivativeCallwrtK(S, K, sigma, r, q, dT, method_cdf='simpson'):
    """
    Derivative formulae of a call w.r.t. the strike price 'K'
    """    
    bse_frame = ComputeOptionBSE(S = S, sigma = sigma, r = r, q = q)
    
    d1 = bse_frame.__ComputeD1__(deltaT = dT, K = K, returnVal=True)
    d2 = bse_frame.__ComputeD2__(deltaT = dT, K = K, returnVal=True)
    
    Nd2 = bse_frame.__GetN__(dvalue = -d2, method = method_cdf)
    
    dN_d1 = derivative_normal(d1)
    dN_d2 = derivative_normal(d2)
    
    firstTerm = np.exp(-r * dT) * ( (K * dN_d2 * 1/(K * sigma * np.sqrt(dT))) -  Nd2) 
    secondTerm = S * np.exp(-q * dT) * dN_d1 * 1/(K * sigma * np.sqrt(dT))
    
    return firstTerm - secondTerm

def NewtonZeroOptionTimeValue(S, x0, dT, q, r, sigma, optionType, method_cdf='simpson', tolerance=10**-6, printx=True): 

    """
    Newton's Computation to solve a 'Zero Option Time Value', i.e.
    
    For a put:
        
        Pbs*(K) = K - S0, given information to compute Pbse(S, K, sigma,...)
        
        Such as:
            f(x0) = Pbse(S, K, sigma,...) - Pbs*(K)
            
            where: K = x0 for newton's Method
            
    For a call:
        
        Cbs*(K) = S0 - K, given information to compute Cbse(S, K, sigma,...)
        
        Such as:
            f(x0) = Cbse(S, K, sigma,...) - Cbs*(K)
            
            where: K = x0 for newton's Method    
    """    
    
    # def initial counter
    counter = 0     
    
    # def of initial guesses
    xnew, xold = x0, x0 - 1
    
    # define general BSE framework (since x0 does not belong to these base params)
    BSEframe = ComputeOptionBSE(S = S, sigma = sigma, r = r, q = q)
    
    # loop initialization with condition
    while (abs(xnew - xold) > tolerance):
        # updating in advance xold by the current xnew 
        xold = xnew
        
        if optionType.lower() =='put':
            # defining the base function wrt 'xold' s.a. Cbse - (K - S)
            fxOld = BSEframe.get(
                    deltaT = dT, 
                    K = xold, 
                    option_type = optionType, 
                    cdf_method = method_cdf
            ) -  (xold - S)
            
            # defining derivative of the put
            dfxOld = derivativePutwrtK(
                S= S, K=xold, sigma=sigma, 
                r=r, q=q, dT=dT, method_cdf=method_cdf
            ) - 1
            
        elif optionType.lower() =='call':
            # defining the base function wrt 'xold' s.a. Cbse - (S - K)
            fxOld = BSEframe.get(
                    deltaT = dT, 
                    K = xold, 
                    option_type = optionType, 
                    cdf_method = method_cdf
            ) -  (S - xold)
            
            # defining derivative of the call
            dfxOld = derivativeCallwrtK(
                S= S, K=xold, sigma=sigma, 
                r=r, q=q, dT=dT, method_cdf=method_cdf
            ) + 1            
            
        
        # computing Newton's Method 
        xnew = xold - (fxOld / dfxOld)
        
        # adding value to the counter
        counter +=1
        # print process if required
        if printx: print(f"X{counter} : {xnew}")
    return xnew


#################################### Problem Typo Q3 - Final Coding Sample Part
def bond_zerorate(t_cashflows, v_cashflows, f_zrate, extrainfo = False):
    """
    Base Dr. Stefanica's Computation to find Price, Duration and Convx. of a bond
    given the Zero Rate (i.e., 'r(0,t)').
    
    Table 2.5., page 66, 2nd Ed.
    
    
    Dont use these to compute duration and convexity... YIELD IS REQUIRED!
    """
    n = len(v_cashflows)
    
    B, D, C = 0, 0, 0
    
    discountFactors = []
    
    for idx in range(n):
        # compute discount factor based on the function of zero rate
        disc = np.exp(-t_cashflows[idx] * f_zrate(t_cashflows[idx]))
        # compute price of the bond
        B = B + (v_cashflows[idx] * disc)
        # check if extra info is required (duration, convexity and save disc factors)
        if extrainfo:
            D = D + (t_cashflows[idx] * v_cashflows[idx] * disc)
            C = C + ((t_cashflows[idx]**2) * v_cashflows[idx] * disc)
            discountFactors.append(disc)
        
    # return bond price, duration and convexity
    if extrainfo:
        return B, D/B, C/B, discountFactors
    else:
        return B

def bond_instrate(t_cashflows, v_cashflows, f_inrate, tolerance_vector,
                  n_intervals = 4, digits = 12, extrainfo = False):
    """
    Base Dr. Stefanica's Computation to find Price, Duration and Convx. of a bond
    given the Instaneous Rate Curve Integral (i.e., 'r(0,t)').
    
    Simpson Method's is using to find the value of the integral for each r(ti)
    
    Table 2.6., page 66, 2nd Ed.
    """    
    n = len(v_cashflows)
    
    assert len(tolerance_vector) == n, f" >> You required {n} values for tolerance"
    
    B, D, C = 0, 0, 0
    
    discountFactors = []
    
    for idx in range(n):
        # compute simpson instantaneus rate numerical value
        simpsonInstantaneusRate =         evaNumericalIntegration(
            a = 0, 
            b = t_cashflows[idx], 
            n = n_intervals, 
            function = f_inrate, 
            tolerance = tolerance_vector[idx], 
            digits=digits
        )
        # extract best approximation
        bestApprox = float(list(simpsonInstantaneusRate.values())[-1])

        # disc factor based on simpson instantaneus rate numerical value
        disc = np.exp(-bestApprox)
        # price of the bond
        B = B + (v_cashflows[idx] * disc)
        # if extra info is required
        if extrainfo:
            # compute convexity and duration, and save disc factors
            D = D + (t_cashflows[idx] * v_cashflows[idx] * disc)
            C = C + ((t_cashflows[idx]**2) * v_cashflows[idx] * disc) 
            discountFactors.append(disc)
    # return bond price, duration and convexity
    if extrainfo:
        return B, D/B, C/B, discountFactors
    else:
        return B

def bond_list_zerorates(cashflows, payment_dates, zero_rate_list):
    """
    Simple function to compute the price of a bond given three lists:
        - cashflow lists
        - coupon payments lists (in the form of 'Period/12')
        - zero_rate_lists 
    """
    result = 0
    
    for idx in range(0, len(cashflows)):
        result += cashflows[idx] * np.exp(-payment_dates[idx] * zero_rate_list[idx])
    return result

def theta_call(S, K, dT, q, r, sigma, method_cdf='simpson'):
    """
    General Function to find the theta for a call.
    """
    
    # define bse framework 
    bseframe = ComputeOptionBSE(S = S, sigma = sigma, r = r, q = q)
    # compute d1
    d1 = bseframe.__ComputeD1__(deltaT=dT, K=K, returnVal=True)
    # compute d2
    d2 = bseframe.__ComputeD2__(deltaT=dT, K=K, returnVal=True)
    # get N(-d1)
    Nd1 = bseframe.__GetN__(d1, method = method_cdf)
    # get N(-d2)
    Nd2 = bseframe.__GetN__(d2, method = method_cdf)
    
    # find first term of tetha
    firstTerm = np.divide(S * sigma * np.exp(-q * dT), 2 * np.sqrt(2 * np.pi * dT)) * np.exp(-(d1**2)/2)
    # find second term of tetha
    secondTerm = q * S * np.exp(-q * dT) * Nd1
    # find third term of tetha
    thirdTerm = -r * K * np.exp(-r * dT) * Nd2
    
    # return tetha
    return firstTerm + secondTerm + thirdTerm    

#############################################################################################################
######################### Implied Volatility for Option Chain Using Newton's Method #########################
#############################################################################################################
def NewtonImpliedVolatilityOptionChain(df, S, dT, q, r, x0, tolerance = 10**-8, cdf_method = 'stefanica'):
    """
    Function that allows to find the implied volatility for European Call/Puts directly from the options change.
    
    The desired input format should be:
    
    Call Price 	Strike 	Put Price
    0 	260.000000 	2150 	35.250000
    1 	238.850006 	2175 	38.950001
    2 	218.149994 	2200 	43.000000
    3 	197.949997 	2225 	47.599998
    4 	178.149994 	2250 	52.650000
    ...    ...      ...     ...
    
    The final output will be a dataframe of the form:
    
            Implied Vol Call 	Implied Vol Put
    Strike 		
    2150.0 	0.173934 	0.174163
    2175.0 	0.169045 	0.169302
    2200.0 	0.164212 	0.164308
    2225.0 	0.159419 	0.159458
    2250.0 	0.154392 	0.154464
    2275.0 	0.149455 	0.149557
    ...    ...      ...     ...
    """
    results = {}
    # iterate over each option in the simplified dataset 'df'
    for idx in range(len(df)):
        # select row info
        rowInfo = df.iloc[idx]
        # find implied vol for the selected call option
        impliedVCall = NewtonBSE(
            Vprice = rowInfo['Call Price'], S = S, K=rowInfo['Strike'], 
            dT=dT, q= q, r=r, x0=x0, 
            option_type = "Call", tol=tolerance, method_cdf=cdf_method, printx=False
        )
        # find implied vol for the selected put option
        impliedVPut = NewtonBSE(
            Vprice = rowInfo['Put Price'], S = S, K=rowInfo['Strike'], 
            dT=dT, q= q, r=r, x0=x0,  
            option_type = "Put", tol=tolerance, method_cdf=cdf_method, printx=False
        )
        # save both results in a single lists
        impliedVols = [impliedVCall, impliedVPut]
        # save the information in the empty dict for a given strike
        results[rowInfo['Strike']] = impliedVols
    
    # transform final result as dataframe
    impVolsQ2ii = pd.DataFrame(
        results, index=["Implied Vol Call", "Implied Vol Put"]
    ).T.rename_axis('Strike')
    
    return impVolsQ2ii

def EmbeddedImpliedVol_NewtonOptionChain(df, dT, PVF, disc, x0, tolerance = 10**-8, cdf_method = 'stefanica'):
    """
    Function that allows to find the implied volatility for European Call/Puts directly from the options change.
    
    THIS FUNCTION DONT NEED "S" PRICE OR "r" AND "q" : only PVF and DISC.
    
    The desired input format should be:
    
    Call Price 	Strike 	Put Price
    0 	260.000000 	2150 	35.250000
    1 	238.850006 	2175 	38.950001
    2 	218.149994 	2200 	43.000000
    3 	197.949997 	2225 	47.599998
    4 	178.149994 	2250 	52.650000
    ...    ...      ...     ...
    
    The final output will be a dataframe of the form:
    
            Implied Vol Call 	Implied Vol Put
    Strike 		
    2150.0 	0.173934 	0.174163
    2175.0 	0.169045 	0.169302
    2200.0 	0.164212 	0.164308
    2225.0 	0.159419 	0.159458
    2250.0 	0.154392 	0.154464
    2275.0 	0.149455 	0.149557
    ...    ...      ...     ...
    """
    
    results = {}
    # iterate over each option in the simplified dataset 'df'
    for idx in range(len(df)):
        # select row info
        rowInfo = df.iloc[idx]
        # find implied vol for the selected call option
        impliedVCall = NewtonBSE_EmbVolatility(
            Vprice = rowInfo['Call Price'], K = rowInfo['Strike'], 
            dT=dT, PVF=PVF, disc=disc, 
            option_type = 'call', x0 = x0, tol=tolerance, method_cdf=cdf_method, printx=False
        )
        # find implied vol for the selected put option
        impliedVPut = NewtonBSE_EmbVolatility(
            Vprice = rowInfo['Put Price'], K = rowInfo['Strike'], 
            dT=dT, PVF=PVF, disc=disc, 
            option_type = 'put', x0 = x0, tol=tolerance, method_cdf=cdf_method, printx=False
        )
        # save both results in a single lists
        impliedVols = [impliedVCall, impliedVPut]
        # save the information in the empty dict for a given strike
        results[rowInfo['Strike']] = impliedVols
    
    # transform final result as dataframe
    impVolsQ2ii = pd.DataFrame(
        results, index=["Implied Vol Call", "Implied Vol Put"]
    ).T.rename_axis('Strike')
    
    return impVolsQ2ii

#################################################################################
# function to get the cashflows of a bond
def get_cashflow(payment_frequency, coupon_rate, time_to_maturity, 
                 annualized_payment_dates = False,
                 face_value = 100, periods_per_year = None, 
                 months = None):
    
    """
    Special function to find the Payments dates and the cashflow of a given bond.
    
    Works as a first step to solve problems like:
    
    "Find the value of a 19 months semiannual coupon bond with 7% coupon rate".
    
    In the former case: 
    
    Input:
        - payment_frequency: 'semiannual'
        - coupon_rate: '3.5'
        - time_to_maturity: '19'
    Output:
        - list payment dates: [3, 9, 15, 21]
        - list coupon payments: [1.75, 1.75, 1.75, 101.75]
    """
    
    # check if time to maturity is int, otherwise raise an error
    assert type(time_to_maturity) == int, "Define 'time_to_maturity' as int, not float type."
    
    if coupon_rate < 0: 
        print(">>> Warning! You are computing with a coupon < 0. Usually it's like 2.5, 3.7, etc.")
    
    if payment_frequency == 'annual':
        periods_per_year, months = 1, 12
    elif payment_frequency == 'semiannual':
        periods_per_year, months = 2, 6
    elif payment_frequency == 'quarterly':
        periods_per_year, months = 4, 3
    elif payment_frequency == 'monthly':
        periods_per_year, months = 12, 1
    elif payment_frequency == 'None':
        # here the func will use the inputs 'periods_per_year' and 'months'
        assert periods_per_year != None, "For 'None' payment_frequency, define 'periods_per_year'"
        assert months != None, "For 'None' payment_frequency, define 'months'"
    else:
        raise ValueError('Invalid payment frequency!')
    
    # get the coupon payment value (for cashflow)
    coupon_payment = coupon_rate / periods_per_year
    
    # empty list to save the periods to maturity
    periods_to_maturity = [time_to_maturity]
    
    # define initial loop time to start while iteratin
    loopTime = time_to_maturity
    
    # define the payments times
    while loopTime - months > 0:
        loopTime = loopTime - months
        periods_to_maturity.append(loopTime)
    periods_to_maturity = periods_to_maturity[::-1]
    
    # empty list to save coupons payments on each period
    couponPaymentValues = []
    for idx in range(0, len(periods_to_maturity)):
        if idx != len(periods_to_maturity) - 1:
            couponPaymentValues.append(coupon_payment)
        else:
            couponPaymentValues.append(face_value + coupon_payment)
    
    if annualized_payment_dates:
        periods_to_maturity = [period/12 for period in periods_to_maturity]

    return periods_to_maturity, couponPaymentValues


######--------------------------- Order this -------------------------#######################################
# We use the Package created for ACFE Homeworks
# from ACFE import * 
import math
import numpy as np
def cum_dist_normal(t):
    z = abs(t)
    y = 1/(1+0.2316419*z)
    a1 = 0.319381530
    a2 = -0.356563782
    a3 = 1.781477937
    a4 = -1.821255978
    a5 = 1.330274429
    m = 1 - ((math.exp(-(t**2)/2)*(a1*y + a2*(y**2)+ a3*(y**3)+ a4*(y**4)+ a5*(y**5)))/((2*math.pi)**0.5))
    if t>0:
        return m
    else:
        return 1-m

    cum_dist_normal()

def BlackSholes(S, K, T, sigma, r, q, optionType):
    d1 = (np.log(S/K) + (r-q+((sigma**2)/2))*(T)) / (sigma * (T)**0.5)
    d2 = d1 - sigma * (T)**0.5
    if optionType == "Call":
        return S*math.exp(-q*(T))*cum_dist_normal(d1) - K*math.exp(-r*(T))*cum_dist_normal(d2)
    if optionType == "Put":
        return K*math.exp(-r*(T))*cum_dist_normal(-d2) - S*math.exp(-q*(T))*cum_dist_normal(-d1)

def VegaBS(S, K, T, sigma, r, q):
    d1 = (np.log(S/K) + (r-q+((sigma**2)/2))*(T)) / (sigma * (T**0.5))
    return (1/((2*math.pi)**0.5))*S* math.exp(-(d1**2)/2)*(T**0.5)

def DeltaBS(S, K, T, sigma, r, q, optionType):
    d1 = (np.log(S/K) + (r-q+((sigma**2)/2))*(T)) / (sigma * (T)**0.5)
    return math.exp(-q*T)*cum_dist_normal(d1)
    
def NewtonBS(x0, tol, final_value, S, K, T, r, q, optionType):
    x_new = x0
    x_old = x0 - 1
    while (abs(x_new - x_old) > tol):
        x_old = x_new
        x_new = x_new - (BlackSholes(S, K, T, x_new, r, q, optionType) - final_value)/VegaBS(S, K, T, x_new, r, q)
    return x_new

def BisectionBS(a, b, tol_int, tol_approx, final_value, S, K, T, r, q, optionType):
    xL = a
    xR = b
    while(max(abs(BlackSholes(S, K, T, xL, r, q, optionType) - final_value), abs(BlackSholes(S, K, T, xR, r, q, optionType) - final_value)) > tol_approx) or (xR - xL > tol_int):
        xM = (xL + xR)/2
        if((BlackSholes(S, K, T, xL, r, q, optionType) - final_value)*(BlackSholes(S, K, T, xM, r, q, optionType) - final_value) < 0):
            xR = xM
        else:
            xL = xM
    return xM

def SecantBS(x_1, x0, tol_approx, tol_consec, final_value, S, K, T, r, q, optionType):
    x_new = x0
    x_old = x_1
    while (abs(BlackSholes(S, K, T, x_new, r, q, optionType) - final_value) > tol_approx) or (abs(x_new - x_old) > tol_consec):
        x_oldest = x_old
        x_old = x_new
        x_new = x_old - ((BlackSholes(S, K, T, x_old, r, q, optionType) - final_value) * (x_old - x_oldest) / ((BlackSholes(S, K, T, x_old, r, q, optionType) - final_value) - (BlackSholes(S, K, T, x_oldest, r, q, optionType) - final_value)))
    return x_new

def BondYieldNewton(B, t_cash_flow, v_cash_flow, tol):
    x0 = 0.1
    x_new = x0
    x_old = x0 - 1
    while (abs(x_new - x_old) > tol):
        x_old = x_new
        term2_numerator = 0
        term2_denominator = 0
        for i in range(0,len(t_cash_flow)):
            term2_numerator += (v_cash_flow[i]*math.exp(-x_old*t_cash_flow[i]))
            term2_denominator += (t_cash_flow[i]*v_cash_flow[i]*math.exp(-x_old*t_cash_flow[i]))
        term2 = (term2_numerator - B)/term2_denominator
        x_new = x_old + term2
    return x_new
                    
def BondPricing(t_cash_flow, v_cash_flow, y):
    B=0
    D=0
    C=0
    disc = []
    for i in range(0, len(t_cash_flow)):
        disc.append(math.exp(-t_cash_flow[i]*y))
        B = B + v_cash_flow[i] * disc[i]
        D = D + t_cash_flow[i]*v_cash_flow[i]*disc[i]
        C = C + (t_cash_flow[i]**2)*v_cash_flow[i]*disc[i]
    return [B, D/B, C/B]

def NewtonDelta(x0, tol_approx, tol_consec, final_value, S, T, sigma, r, q, optionType):
    x_new = x0
    x_old = x0 - 1
    while (abs(DeltaBS(S, x_new, T, sigma, r, q, optionType) - final_value) > tol_approx) or (abs(x_new - x_old) > tol_consec):
        x_old = x_new
        d1 = (np.log(S/x_old) + (r-q+((sigma**2)/2))*(T)) / (sigma * (T)**0.5)
        x_new = x_old + ((math.exp(-q*T)*cum_dist_normal(d1) - final_value)*x_old*sigma*np.sqrt(T*2*math.pi)/(math.exp(-q*T-(d1**2)/2)))
    return x_new

def ThetaPut(x_old, K, T, sigma, r, q, optionType):
    d1 = (np.log(x_old) + (r-q+((sigma**2)/2))*(T)) / (sigma * (T)**0.5)
    d2 = d1 - sigma * (T)**0.5
    return -((x_old*K*sigma*math.exp(-q*T))/(2*np.sqrt(2*math.pi*T)))*math.exp(-(d1**2)/2)-(q*x_old*K*math.exp(-q*T)*cum_dist_normal(-d1))+(r*K*math.exp(-r*T)*cum_dist_normal(-d2))

