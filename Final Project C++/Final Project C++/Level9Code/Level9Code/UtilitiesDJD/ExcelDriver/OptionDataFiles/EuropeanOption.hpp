/*
EuropeanOption.hpp
Header of a class EuropeanOption
Class that represents  solutions to European options. This is an implementation using basic C++ syntax only.
*/
#ifndef EuropeanOption_hpp
#define EuropeanOption_hpp
#include <string>
#include <vector>
#include <map>
#include <iostream>
#include <sstream>
#include "Option.hpp"
using namespace std;
namespace GERALD
{
	namespace OPTIONS
	{
		class EuropeanOption : public Option
		{
		public:
			// Constructor and Destructor
			EuropeanOption();																			// Default call option
			EuropeanOption(double r, double sigma, double K, double T, double b,
				string optionType, string nameAsset);													// Parameters Constructor
			EuropeanOption(const Batch& batch);											// Parameters Constructor using a vector of tuple
			EuropeanOption(const EuropeanOption& source);												// Copy constructor
			virtual ~EuropeanOption();

			// Member operator overloading
			EuropeanOption& operator=(const EuropeanOption& source);									// assignment operator

			// Utilities functions
			double N(const double& value) const;																// cumulative distribution of standard normal variable
			double n(const double& value) const;																// probability distribution of standard normal variable

			// Put-Call Parity
			double PutCallParity_calculate(double S) const;													// Put-Call parity to calculate put or call price
			void PutCallParity_check(double S, const EuropeanOption& Option) const;														// Put-Call parity to calculate put or call price

			// Pricer Function
			virtual double Pricer(double S) const;																// Pricer function for options using 1 parameter

			// Greeks Function
			double Delta(double S) const;																			// Delta function for options
			double Gamma(double S) const;																			// Gamma function for options
			double Vega(double S) const;																			// Vega function for options
			double Theta(double S) const;																			// Theta function for options

			// Function that approximate to Abstract Functions Greeks
			double DeltaApproximation(double S, double h) const;											// Approximation of Delta
			double GammaApproximation(double S, double h) const;											// Approximation of Gamma


		};
	}
}

#endif

