/*
PerpetualAmericanOption.hpp
Header of a class PerpetualAMericanOption
Class that represents  solutions to Perpetual American options. This is an implementation using basic C++ syntax only.
*/
#ifndef PerpetualAmericanOption_hpp
#define PerpetualAmericanOption_hpp
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
		class PerpetualAmericanOption : public Option
		{
		public:
			// Constructor and Destructor
			PerpetualAmericanOption();																			// Default call option
			PerpetualAmericanOption(double r, double sigma, double K, double T, double b,
				string optionType, string nameAsset);															// Parameters Constructor
			PerpetualAmericanOption(const Batch& batch);															// Parameters Constructor using Batch
			PerpetualAmericanOption(const PerpetualAmericanOption& source);										// Copy constructor
			virtual ~PerpetualAmericanOption();

			// Member operator overloading
			PerpetualAmericanOption& operator=(const PerpetualAmericanOption& source);							// assignment operator

			// Pricer
			virtual double Pricer(double S) const;	// Pricer function for options using 1 parameter




		};
	}
}
#endif
