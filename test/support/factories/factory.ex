defmodule VmsServer.Factory do
  alias VmsServer.Sheet.{
    User,
    Race,
    Character,
    Chronicle,
    SubCategory,
    Category,
    Characteristics,
    CharacteristicsLevel,
    DynamicCharacteristics,
    DynamicCharacteristicsLevel,
    RaceCharacteristics
  }

  use ExMachina.Ecto, repo: VmsServer.Repo

  def user_factory do
    %User{
      name: "Assis neto",
      email: "assisneto@email.com",
      hashed_password: "Pdiosjado123123123[][0-2]",
      password: "A23ksda()"
    }
  end

  def race_factory do
    %Race{
      name: "Vampire",
      description: "Elegant and wise"
    }
  end

  def chronicle_factory do
    %User{id: storyteller_id} = insert(:user)

    %Chronicle{
      title: "Rise and fall of noob saibot",
      description: "Demon noob saibot",
      storyteller_id: storyteller_id
    }
  end

  def character_factory do
    %User{id: user_id} = insert(:user)
    %Race{id: race_id} = insert(:race)
    %Chronicle{id: chronicle_id} = insert(:chronicle)

    %Character{
      name: "Marcos Capella",
      bashing: 0,
      lethal: 0,
      aggravated: 0,
      race_id: race_id,
      user_id: user_id,
      chronicle_id: chronicle_id
    }
  end

  def sub_category_factory do
    %SubCategory{
      type: Enum.random(SubCategory.type_enum())
    }
  end

  def category_factory do
    %SubCategory{id: sub_category_id} = insert(:sub_category)

    %Category{
      sub_category_id: sub_category_id,
      type: Enum.random(Category.type_enum()),
      race_id: nil
    }
  end

  def category_with_race_factory do
    %SubCategory{id: sub_category_id} = insert(:sub_category)
    %Race{id: race_id} = insert(:race)

    %Category{
      sub_category_id: sub_category_id,
      type: Enum.random(Category.type_enum()),
      race_id: race_id
    }
  end

  def characteristics_factory do
    %Category{id: category_id} = insert(:category)

    %Characteristics{
      name: "Dexterity",
      description: "Defines the character's agility level",
      category_id: category_id,
      character_id: nil
    }
  end

  def characteristics_level_factory do
    %Character{id: character_id} = insert(:character)
    %Characteristics{id: characteristic_id} = insert(:characteristics)

    %CharacteristicsLevel{
      character_id: character_id,
      characteristic_id: characteristic_id,
      level: Enum.random(0..5)
    }
  end

  def dynamic_characteristics_factory do
    %Category{id: category_id} = insert(:category)

    %DynamicCharacteristics{
      name: "Brawler",
      description: "Fight",
      category_id: category_id,
      character_id: nil
    }
  end

  def dynamic_characteristics_level_factory do
    %Character{id: character_id} = insert(:character)
    %DynamicCharacteristics{id: dynamic_characteristic_id} = insert(:dynamic_characteristics)

    %DynamicCharacteristicsLevel{
      character_id: character_id,
      characteristic_id: dynamic_characteristic_id,
      level: Enum.random(1..10),
      used: Enum.random(0..5)
    }
  end

  def race_characteristics_factory do
    %Character{id: character_id} = insert(:character)

    %RaceCharacteristics{
      key: "Agility",
      value: "High",
      character_id: character_id
    }
  end
end
