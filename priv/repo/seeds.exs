# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Portal.Repo.insert!(%Portal.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Portal.Repo

alias Portal.ManpowerRanges.ManpowerRange
alias Portal.Industries.Industry
alias Portal.RevenueRanges.RevenueRange

# Seed Manpower ranges
manpower_ranges = [
  %{name: "1-10", code: "MR001", min_value: 1, max_value: 10},
  %{name: "11-50", code: "MR002", min_value: 11, max_value: 50},
  %{name: "51-200", code: "MR003", min_value: 51, max_value: 200},
  %{name: "201-500", code: "MR004", min_value: 201, max_value: 500},
  %{name: "501-1000", code: "MR005", min_value: 501, max_value: 1000},
  %{name: "1001-5000", code: "MR006", min_value: 1001, max_value: 5000},
  %{name: "5001-10000", code: "MR007", min_value: 5001, max_value: 10000},
  %{name: "10001+", code: "MR008", min_value: 10001, max_value: nil}
]

Enum.each(manpower_ranges, fn range ->
  Repo.insert!(ManpowerRange.changeset(%ManpowerRange{}, range),
    on_conflict: :replace_all,
    conflict_target: [:code]
  )
end)

# Seed Revenue Ranges
revenue_ranges = [
  %{name: "< $1M", code: "RR001", min_value: 0, max_value: 1_000_000},
  %{name: "$1M - $10M", code: "RR002", min_value: 1_000_001, max_value: 10_000_000},
  %{name: "$10M - $50M", code: "RR003", min_value: 10_000_001, max_value: 50_000_000},
  %{name: "$50M - $100M", code: "RR004", min_value: 50_000_001, max_value: 100_000_000},
  %{name: "$100M - $500M", code: "RR005", min_value: 100_000_001, max_value: 500_000_000},
  %{name: "$500M - $1B", code: "RR006", min_value: 500_000_001, max_value: 1_000_000_000},
  %{name: "> $1B", code: "RR007", min_value: 1_000_000_001, max_value: nil}
]

Enum.each(revenue_ranges, fn range ->
  Repo.insert!(RevenueRange.changeset(%RevenueRange{}, range),
    on_conflict: :replace_all,
    conflict_target: [:code]
  )
end)

# Seed Industries
industries = [
  # Technology & Information Services
  %{"name" => "Information Technology", "code" => "IT", "sector" => "Technology"},
  %{"name" => "Software Development", "code" => "SOFT-DEV", "sector" => "Technology"},
  %{"name" => "Telecommunications", "code" => "TELECOM", "sector" => "Technology"},
  %{"name" => "Information Services", "code" => "INFO-SERV", "sector" => "Technology"},
  %{"name" => "E-Learning", "code" => "E-LEARN", "sector" => "Technology"},
  %{"name" => "Cybersecurity", "code" => "CYBERSEC", "sector" => "Technology"},
  %{"name" => "Artificial Intelligence", "code" => "AI", "sector" => "Technology"},

  # Healthcare & Life Sciences
  %{"name" => "Healthcare Services", "code" => "HEALTH-SERV", "sector" => "Healthcare"},
  %{"name" => "Pharmaceuticals", "code" => "PHARMA", "sector" => "Healthcare"},
  %{"name" => "Biotechnology", "code" => "BIOTECH", "sector" => "Healthcare"},
  %{"name" => "Medical Devices", "code" => "MED-DEV", "sector" => "Healthcare"},

  # Finance & Business Services
  %{"name" => "Banking", "code" => "BANK", "sector" => "Finance"},
  %{"name" => "Insurance", "code" => "INS", "sector" => "Finance"},
  %{"name" => "Investment Banking", "code" => "INV-BANK", "sector" => "Finance"},
  %{"name" => "Investment Management", "code" => "INV-MGMT", "sector" => "Finance"},
  %{"name" => "Venture Capital & Private Equity", "code" => "VC-PE", "sector" => "Finance"},
  %{"name" => "Financial Services", "code" => "FIN-SERV", "sector" => "Finance"},
  %{"name" => "Accounting", "code" => "ACCT", "sector" => "Finance"},
  %{"name" => "Management Consulting", "code" => "MGMT-CONS", "sector" => "Business Services"},
  %{"name" => "Human Resources", "code" => "HR", "sector" => "Business Services"},
  %{"name" => "Legal Services", "code" => "LEGAL", "sector" => "Business Services"},

  # Education
  %{"name" => "Higher Education", "code" => "EDU-HIGH", "sector" => "Education"},
  %{"name" => "Primary/Secondary Education", "code" => "EDU-K12", "sector" => "Education"},
  %{"name" => "Education Management", "code" => "EDU-MGMT", "sector" => "Education"},
  %{"name" => "Professional Training & Coaching", "code" => "PRO-TRAIN", "sector" => "Education"},

  # Manufacturing & Industry
  %{"name" => "Automotive Manufacturing", "code" => "AUTO-MFG", "sector" => "Manufacturing"},
  %{"name" => "Aerospace Manufacturing", "code" => "AERO-MFG", "sector" => "Manufacturing"},
  %{"name" => "Electronics Manufacturing", "code" => "ELEC-MFG", "sector" => "Manufacturing"},
  %{"name" => "Food & Beverage Production", "code" => "FOOD-PROD", "sector" => "Manufacturing"},
  %{"name" => "Textiles Manufacturing", "code" => "TEXT-MFG", "sector" => "Manufacturing"},
  %{"name" => "Chemical Manufacturing", "code" => "CHEM-MFG", "sector" => "Manufacturing"},
  %{"name" => "Industrial Automation", "code" => "IND-AUTO", "sector" => "Manufacturing"},
  %{"name" => "Machinery Manufacturing", "code" => "MACH-MFG", "sector" => "Manufacturing"},

  # Energy & Utilities
  %{"name" => "Oil & Gas", "code" => "OIL-GAS", "sector" => "Energy"},
  %{"name" => "Renewable Energy", "code" => "RENEW-ENERGY", "sector" => "Energy"},
  %{"name" => "Utilities", "code" => "UTIL", "sector" => "Energy"},

  # Retail & Consumer Goods
  %{"name" => "Retail", "code" => "RETAIL", "sector" => "Retail & Consumer Goods"},
  %{"name" => "E-commerce", "code" => "E-COM", "sector" => "Retail & Consumer Goods"},
  %{
    "name" => "Consumer Goods Manufacturing",
    "code" => "CONS-GOODS",
    "sector" => "Retail & Consumer Goods"
  },
  %{
    "name" => "Luxury Goods & Jewelry",
    "code" => "LUX-GOODS",
    "sector" => "Retail & Consumer Goods"
  },

  # Transportation & Logistics
  %{"name" => "Airlines", "code" => "AIRLINE", "sector" => "Transportation"},
  %{"name" => "Logistics & Supply Chain", "code" => "LOGISTICS", "sector" => "Transportation"},
  %{"name" => "Shipping & Marine Transport", "code" => "SHIPPING", "sector" => "Transportation"},
  %{"name" => "Railroad Transportation", "code" => "RAILROAD", "sector" => "Transportation"},

  # Construction & Real Estate
  %{"name" => "Construction", "code" => "CONSTR", "sector" => "Construction"},
  %{"name" => "Architecture & Planning", "code" => "ARCH-PLAN", "sector" => "Construction"},
  %{"name" => "Real Estate", "code" => "REAL-EST", "sector" => "Real Estate"},
  %{"name" => "Property Management", "code" => "PROP-MGMT", "sector" => "Real Estate"},

  # Agriculture & Mining
  %{"name" => "Agriculture", "code" => "AGRI", "sector" => "Agriculture"},
  %{"name" => "Farming", "code" => "FARM", "sector" => "Agriculture"},
  %{"name" => "Mining & Metals", "code" => "MINING", "sector" => "Mining"},

  # Media & Entertainment
  %{"name" => "Media Production", "code" => "MEDIA-PROD", "sector" => "Media & Entertainment"},
  %{"name" => "Broadcasting", "code" => "BROADCAST", "sector" => "Media & Entertainment"},
  %{"name" => "Gaming", "code" => "GAMING", "sector" => "Media & Entertainment"},
  %{"name" => "Performing Arts", "code" => "PERF-ARTS", "sector" => "Media & Entertainment"},

  # Hospitality & Tourism
  %{"name" => "Hotels & Resorts", "code" => "HOTELS", "sector" => "Hospitality & Tourism"},
  %{
    "name" => "Restaurants & Food Service",
    "code" => "FOOD-SERV",
    "sector" => "Hospitality & Tourism"
  },
  %{"name" => "Travel & Tourism", "code" => "TRAVEL", "sector" => "Hospitality & Tourism"},

  # Professional Services
  %{
    "name" => "Marketing & Advertising",
    "code" => "MKTG-ADV",
    "sector" => "Professional Services"
  },
  %{"name" => "Public Relations", "code" => "PR", "sector" => "Professional Services"},
  %{"name" => "Design Services", "code" => "DESIGN", "sector" => "Professional Services"},

  # Government & Non-Profit
  %{"name" => "Government Administration", "code" => "GOV-ADMIN", "sector" => "Government"},
  %{"name" => "Non-Profit Organizations", "code" => "NON-PROFIT", "sector" => "Non-Profit"},
  %{"name" => "International Affairs", "code" => "INTL-AFFAIRS", "sector" => "Government"},

  # Defense & Aerospace
  %{
    "name" => "Defense & Space Technology",
    "code" => "DEF-SPACE",
    "sector" => "Defense & Aerospace"
  },

  # Environmental Services
  %{
    "name" => "Environmental Consulting",
    "code" => "ENV-CONS",
    "sector" => "Environmental Services"
  },
  %{"name" => "Waste Management", "code" => "WASTE-MGMT", "sector" => "Environmental Services"},

  # Research & Development
  %{"name" => "Scientific Research", "code" => "SCI-RES", "sector" => "Research & Development"},

  # Sports & Recreation
  %{"name" => "Professional Sports", "code" => "PRO-SPORTS", "sector" => "Sports & Recreation"},
  %{"name" => "Recreational Facilities", "code" => "REC-FAC", "sector" => "Sports & Recreation"}
]

Enum.each(industries, fn industry ->
  Repo.insert!(Industry.changeset(%Industry{}, industry),
    on_conflict: :replace_all,
    conflict_target: [:code]
  )
end)
