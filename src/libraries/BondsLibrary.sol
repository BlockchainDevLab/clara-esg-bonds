// SPDX-License-Identifier: MIT
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

pragma solidity ^0.8.20;

struct TypeBonds {
    uint256 TypeID;
    string Name;
    string Description;
    string Fee;
    uint256 MaxSupply;
    uint256[] idxMetadatas;
    mapping(uint256 => Metadata) Metadatas;
}

struct TreasuryBonds {
    uint256 Id;
    uint256 TypeID;
    string Code;
    string CodeISIN;
    string Name;
    string Ratings;
    uint256 MaturityDate;
    uint256 Amount;
    mapping(uint256 => Values) Values;
}

struct Metadata {
    string Title;
    string _Type;
    string Description;
    bytes32 RoleAcess;
}

struct Values {
    string stringValue;
    uint256 uintValue;
    address addressValue;
    bool boolValue;
    bytes32 bytesValue;
}

struct TreasuryBondsValue {
    string Title;
    string _Type;
    string Description;
    string Value;
}

struct Transaction {
    uint256 Id;
    uint256 TypeID;
    string Name;
    string Code;
    string CodeISIN;
    uint256 Amount;
    uint256 MaturityDate;
}

function getStringValue(string memory typeValue, Values memory values) pure returns (string memory) {
    string memory vl = "";
    if (Strings.equal(typeValue, "int")) {
        vl = Strings.toString(values.uintValue);
    } else if (Strings.equal(typeValue, "string")) {
        vl = values.stringValue;
    } else if (Strings.equal(typeValue, "address")) {
        vl = Strings.toHexString(values.addressValue);
    } else if (Strings.equal(typeValue, "bool")) {
        vl = values.boolValue ? "true" : "false";
    } else if (Strings.equal(typeValue, "bytes32")) {
        vl = string(abi.encodePacked(values.bytesValue));
    } else {
        vl = "";
    }

    return vl;
}

// ------------------------------------------------------------------------
// Calculate year/month/day from the number of days since 1970/01/01 using
// the date conversion algorithm from
//   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
// and adding the offset 2440588 so that 1970/01/01 is day 0
//
// int L = days + 68569 + offset
// int N = 4 * L / 146097
// L = L - (146097 * N + 3) / 4
// year = 4000 * (L + 1) / 1461001
// L = L - 1461 * year / 4 + 31
// month = 80 * L / 2447
// dd = L - 2447 * month / 80
// L = month / 11
// month = month + 2 - 12 * L
// year = 100 * (N - 49) + year + L
// ------------------------------------------------------------------------

uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
uint256 constant SECONDS_PER_HOUR = 60 * 60;
uint256 constant SECONDS_PER_MINUTE = 60;
int256 constant OFFSET19700101 = 2440588;

function _daysToDate(uint256 _days) pure returns (uint256 year, uint256 month, uint256 day) {
    int256 __days = int256(_days);

    int256 L = __days + 68569 + OFFSET19700101;
    int256 N = (4 * L) / 146097;
    L = L - (146097 * N + 3) / 4;
    int256 _year = (4000 * (L + 1)) / 1461001;
    L = L - (1461 * _year) / 4 + 31;
    int256 _month = (80 * L) / 2447;
    int256 _day = L - (2447 * _month) / 80;
    L = _month / 11;
    _month = _month + 2 - 12 * L;
    _year = 100 * (N - 49) + _year + L;

    year = uint256(_year);
    month = uint256(_month);
    day = uint256(_day);
}

function TimestampToDateYMD(uint256 timestamp) pure returns (uint256 year, uint256 month, uint256 day) {
    (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
}
