# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     VmsServer.Repo.insert!(%VmsServer.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias VmsServer.Repo
alias VmsServer.Utils.Utils

alias VmsServer.Sheet.{
  SubCategory,
  Race
}

characteristic_set = %{
  attributes: %{
    physical: [:strength, :dexterity, :stamina],
    social: [:charisma, :manipulation, :appearance],
    mental: [:perception, :intelligence, :wits]
  },
  abilities: %{
    talents: [
      :alertness,
      :athletics,
      :brawl,
      :dodge,
      :empathy,
      :expression,
      :intimidation,
      :leadership,
      :streetwise,
      :subterfuge
    ],
    skills: [
      :animal_ken,
      :crafts,
      :drive,
      :etiquette,
      :firearms,
      :melee,
      :performance,
      :security,
      :stealth,
      :survival
    ],
    knowledges: [
      :academics,
      :computer,
      :finance,
      :investigation,
      :law,
      :linguistics,
      :medicine,
      :occult,
      :politics,
      :science
    ]
  },
  benefits: %{
    virtues: [
      :conscience,
      :self_control,
      :courage
    ],
    renown: [
      {:glory, :dynamic},
      {:honor, :dynamic},
      {:wisdom, :dynamic}
    ],
    spheres: [
      :correspondence,
      :entropy,
      :forces,
      :life,
      :matter,
      :mind,
      :prime,
      :spirit,
      :time
    ],
    others: [
      {:willpower, :dynamic}
    ]
  }
}

mage = Race.changeset(%{name: "Mage", description: "Magika"}) |> Repo.insert!()
vampire = Race.changeset(%{name: "Vampire", description: "Blood"}) |> Repo.insert!()
werewolf = Race.changeset(%{name: "Werewolf", description: "Rage"}) |> Repo.insert!()

categories_set = %{
  attributes: [:physical, :social, :mental],
  abilities: [:talents, :skills, :knowledges],
  benefits: [
    :flaws,
    :merits,
    :backgrounds,
    {:virtues, vampire.id},
    {:disciplines, vampire.id},
    {:gifts, werewolf.id},
    {:renown, werewolf.id},
    {:spheres, mage.id},
    :others
  ]
}

sub_categories = Utils.insert_sub_categories(SubCategory.type_enum())
Utils.insert_categories_and_characteristics(categories_set, characteristic_set, sub_categories)
