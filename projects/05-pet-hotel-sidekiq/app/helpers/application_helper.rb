module ApplicationHelper
  # Centavos (integer) → "R$ 80,00". Sem Float.
  def format_money(cents)
    cents = cents.to_i
    sign = cents.negative? ? "-" : ""
    cents = cents.abs
    reais = cents / 100
    centavos = cents % 100
    "#{sign}R$ #{reais},#{format('%02d', centavos)}"
  end

  def stay_status_label(status)
    {
      "scheduled" => "Agendada",
      "checked_in" => "Hospedado",
      "checked_out" => "Check-out"
    }.fetch(status.to_s, status.to_s)
  end
end
