/*
EuropeanOption.cpp
Source file of a class EuropeanOption
Class that represents  solutions to European options. This is an implementation using basic C++ syntax only.
*/
#include "EuropeanOption.hpp"
#include <boost/math/distributions/normal.hpp>
#include <boost/math/distributions.hpp> // For non-member functions of distributions
using namespace boost::math;

namespace GERALD
{
	namespace OPTIONS
	{
		// Constructors and Destructor
		EuropeanOption::EuropeanOption() : Option() {}

		EuropeanOption::EuropeanOption(double r, double sigma, double K, double T, double b, string optionType, string nameAsset) :
			Option(r, sigma, K, T, b, optionType, nameAsset) {}

		EuropeanOption::EuropeanOption(const Batch& batch): // I used the defined type of tuple Batch as parameter input for EuropeanOpition constructor
			Option(std::get<0>(batch), std::get<1>(batch), std::get<2>(batch),std::get<3>(batch), std::get<4>(batch),std::get<5>(batch), std::get<6>(batch)){}

		EuropeanOption::EuropeanOption(const EuropeanOption& source) :
			Option(source) {}

		EuropeanOption::~EuropeanOption() {}

		// Member operator overloading
		EuropeanOption& EuropeanOption::operator=(const EuropeanOption& source)
		{
			Option::operator=(source);
			if (this == &source) // return this if object is equal
			{
				return *this;
			}
			return *this;
		}

		// Other Functions
		double EuropeanOption::N(const double& value) const
		{
			normal_distribution<> Normal(0.0, 1.0); // standard normal distribution with mean 0.0 and standard deviation 1.0
			return cdf(Normal, value);
		}

		double EuropeanOption::n(const double& value) const
		{
			normal_distribution<> Normal(0.0, 1.0); // standard normal distribution with mean 0.0 and standard deviation 1.0
			return pdf(Normal, value);
		}

		// Put-Call parity
		double EuropeanOption::PutCallParity_calculate(double S) const
		{
			if (optionType() == "Call")
			{
				return Pricer(S) - S + K() * exp(-r() * T()); // Put Call parity to calculate call price
			}
			if (optionType() == "Put")
			{
				return Pricer(S) + S - K() * exp(-r() * T()); // Put call parity to calculate put price
			}
		}

		void EuropeanOption::PutCallParity_check(double S, const EuropeanOption& Option) const
		{
			cout << "Does the Put-Option parity holds?: ";
			if (optionType() == "Call")
			{
				cout << std::boolalpha << (Option.Pricer(S) - Pricer(S) + S == K() * exp(-r() * T())) << endl; // Put Call parity to verify call
			}
			if (optionType() == "Put")
			{
				cout << std::boolalpha << (Pricer(S) - Option.Pricer(S) + S == K() * exp(-r() * T())) << endl; // Put call parity to verify Put
			}
		}


		// Pricer
		double EuropeanOption::Pricer(double S) const
		{
			double d1 = d(S)[0]; // Get d1 for option pricing
			double d2 = d(S)[1]; // Get d2 for option pricing

			if (optionType() == "Call")
			{
				return (S * exp((b() - r()) * T()) * N(d1)) - (K() * exp(-r() * T()) * N(d2)); // formula for pricing an european call
			}
			if (optionType() == "Put")
			{
				return (K() * exp(-r() * T()) * N(-d2)) - (S * exp((b() - r()) * T()) * N(-d1)); // formula for pricing an european put
			}
		}

		// Greeks
		double EuropeanOption::Delta(double S) const
		{
			double d1 = d(S)[0]; // Get d1 for option pricing
			double d2 = d(S)[1]; // Get d2 for option pricing
			if (optionType() == "Call")
			{
				return exp((b() - r()) * T()) * N(d1);   // formula for delta call
			}
			if (optionType() == "Put")
			{
				return  -exp((b() - r()) * T()) * N(-d1); // formula for delta put
			}
		}

		double EuropeanOption::Gamma(double S) const
		{
			double d1 = d(S)[0]; // Get d1 for option pricing
			return n(d1) * exp((b() - r()) * T()) / (S * sigma() * pow(T(), 0.5)); // formular for gamma call and put
		}

		double EuropeanOption::Vega(double S) const
		{
			double d1 = d(S)[0]; // Get d1 for option pricing
			return S * pow(T(), 0.5) * exp((b() - r()) * T()) * n(d1); // formula for vega call and put
		}

		double EuropeanOption::Theta(double S) const
		{
			double d1 = d(S)[0]; // Get d1 for option pricing
			double d2 = d(S)[1]; // Get d2 for option pricing
			if (optionType() == "Call")
			{
				return  (-S * sigma() * exp((b() - r()) * T()) * n(d1) / (2 * pow(T(), 0.5))) -
					((b() - r()) * S * exp((b() - r()) * T()) * N(d1)) -
					(r() * K() * exp(-r() * T()) * N(d2));										// formula for theta call
			}
			if (optionType() == "Put")
			{
				return  (-S * sigma() * exp((b() - r()) * T()) * n(d1) / (2 * pow(T(), 0.5))) -
					((b() - r()) * S * exp((b() - r()) * T()) * N(-d1)) -
					(r() * K() * exp(-r() * T()) * N(-d2));										// formula for theta put
			}
		}

		// Function that approximate to Abstract Functions Greeks
		double EuropeanOption::DeltaApproximation(double S, double h) const
		{
			return (Pricer(S + h) - Pricer(S - h)) / (2.0 * h); // formula for approximation of delta
		}

		double EuropeanOption::GammaApproximation(double S, double h) const
		{
			return (Pricer(S + h) - 2 * Pricer(S) + Pricer(S - h)) / pow(h, 2.0); // formula for approximation of gamma
		}
	}
}
