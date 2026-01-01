defmodule TwentyDollarClub.Repo.Migrations.ConvertContributionEnumsToText do
  use Ecto.Migration

  def up do
    #
    # Check column types are correct
    # check constraints
    #

    # For status column
    execute """
    ALTER TABLE contributions
    ADD CONSTRAINT contributions_status_check
    CHECK (status IN ('pending', 'completed', 'failed', 'cancelled'))
    """

    # For payment_method column
    execute """
    ALTER TABLE contributions
    ADD CONSTRAINT contributions_payment_method_check
    CHECK (payment_method IN ('mpesa', 'card', 'cash'))
    """
  end

  def down do
    execute "ALTER TABLE contributions DROP CONSTRAINT IF EXISTS contributions_status_check"
    execute "ALTER TABLE contributions DROP CONSTRAINT IF EXISTS contributions_payment_method_check"
  end
end
