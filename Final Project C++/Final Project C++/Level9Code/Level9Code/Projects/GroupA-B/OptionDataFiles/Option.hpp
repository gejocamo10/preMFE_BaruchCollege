/*
EuropeanOption.hpp
Header of a class Option
Abstract Class that has relevant functions that defined an option. This is an implementation using basic C++ syntax only.
*/

#ifndef Option_hpp
#define Option_hpp
#include <string>
#include <sstream>
#include <vector>
using namespace std;
typedef std::tuple<double, double, double, double, double, string, string, double> Batch;
namespace GERALD
{
	namespace OPTIONS
	{
		class Option
		{
		private:
			double m_r;						// Interest rate
			double m_sigma;					// Volatility
			double m_K;						// Strike price
			double m_T;						// Expiry date
			double m_b;						// cost of carry
			string m_optionType;			// Option name (call, put)
			string m_nameAsset;				// Name of underlying asset

		public:
			// Constructor and Destructor
			Option();							// Default call option
			Option(double r, double sigma, double K, double T, double b,
				string optionType, string nameAsset);		// Parameter Constructor
			Option(const Option& source);					// Copy constructor
			virtual ~Option();

			// Selectors
			// We use default inline functions
			double r() const { return m_r; }				// Get interest rate
			double sigma() const { return m_sigma; }		// Get volatility
			double K() const { return m_K; }				// Get strike price
			double T() const { return m_T; }				// Get expiry date
			double b() const { return m_b; }				// Get cost of carry
			string optionType() const { return m_optionType; }		// Get option name (call, put)
			string nameAsset() const { return m_nameAsset; }		// Get name of underlying asst


			// Modifiers
			// We use default inline functions
			void r(double new_r) { m_r = new_r; }					// Modify interest rate
			void sigma(double new_sigma) { m_sigma = new_sigma; }	// Modify volatility
			void K(double new_K) { m_K = new_K; }					// Modify strike
			void T(double new_T) { m_T = new_T; }					// Modify expiry date
			void b(double new_b) { m_b = new_b; }					// Modify cost of carry
			void optionType(string new_optionType) { m_optionType = new_optionType; }		// Modify option name (call, put)
			void nameAsset(string new_nameAsset) { m_nameAsset = new_nameAsset; }			// Modify name of underlying asset

			// Member operator overloading
			Option& operator=(const Option& source);// assignment operator

			// Other function
			virtual std::vector<double> d(double S) const;		// d1 and d2 for European option pricing
			virtual std::vector<double> y() const;			// y1 and y2 for American option pricing

			// Abstract Function
			virtual double Pricer(double S) const = 0;	// Pricer function for options
		};
	}
}


#endif
