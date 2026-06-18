//! Optimization of logic networks

mod aig;
mod balance;
mod infer_gates;
mod share_logic;

pub use aig::to_aig;
pub use balance::{balance, balance_with};
pub use infer_gates::{infer_dffe, infer_xor_mux};
pub use share_logic::share_logic;
