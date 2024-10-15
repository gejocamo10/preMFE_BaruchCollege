/*
PerpetualAmericanOption.cpp
Source file of a class EuropeanOption
Class that represents  solutions to European options. This is an implementation using basic C++ syntax only.
*/
#include "PerpetualAmericanOption.hpp"
namespace GERALD
{
	namespace OPTIONS
	{
		// Constructors and Destructor
		PerpetualAmericanOption::PerpetualAmericanOption() : Option() {}

		PerpetualAmericanOption::PerpetualAmericanOption(double r, double sigma, double K, double T, double b, string optionType, string nameAsset) :
			Option(r, sigma, K, T, b, optionType, nameAsset) {}

		PerpetualAmericanOption::PerpetualAmericanOption(const Batch& batch): // Constructor that use define type of tuple Batch as parameter
			Option(std::get<0>(batch), std::get<1>(batch), std::get<2>(batch), std::get<3>(batch), std::get<4>(batch), std::get<5>(batch), std::get<6>(batch)) {}

		PerpetualAmericanOption::PerpetualAmericanOption(const PerpetualAmericanOption& source) :
			Option(source) {}

		PerpetualAmericanOption::~PerpetualAmericanOption() {}



		// Member operator overloading
		PerpetualAmericanOption& PerpetualAmericanOption::operator=(const PerpetualAmericanOption& source)
		{
			Option::operator=(source);
			if (this == &source)
			{
				return *this;
			}
			return *this;
		}

		// Derived Abstract functions
		double PerpetualAmericanOption::Pricer(double S) const
		{
			double y1 = y()[0]; // Get d1 for option pricing
			double y2 = y()[1]; // Get d2 for option pricing

			if (optionType() == "Call")
			{
				return K() / (y1 - 1) * pow(((y1 - 1) / y1) * S / K(), y1); // formula for pricing perpetual american call
			}
			if (optionType() == "Put")
			{
				return K() / (1 - y2) * pow(((y2 - 1) / y2) * S / K(), y2); // formula for pricing perpetual american put
			}
		}
	}
}


