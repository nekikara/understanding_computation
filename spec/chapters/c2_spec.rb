require 'pry'
require './chapters/c2'

describe "chapter 2 spec" do
  let(:num1) { Number.new(1) }
  let(:num2) { Number.new(2) }
  let(:num3) { Number.new(3) }
  let(:num4) { Number.new(4) }
  describe Number do
    let(:num) { Number.new(2) }
    describe '#to_s' do
      it do
        expect(num.inspect).to eq "<<2>>"
      end
    end

    describe '#reducible?' do
      it 'true' do
        expect(num.reducible?).to be_falsey
      end
    end
  end

  describe Add do
    let(:add1) { Add.new(num1, num2) }
    describe '#to_s' do
      it do
        adding = Add.new(Multiply.new(num1, num2), Multiply.new(num3, num4))
        expect(adding.inspect).to eq "<<1 * 2 + 3 * 4>>"
      end
    end

    describe '#reducible?' do
      it 'true' do
        expect(add1.reducible?).to be_truthy
      end
    end

    describe '#reduce' do
      context '式の左が簡約可能であれば' do
        let(:add) { Add.new(Add.new(num1, num2), num2) }
        it '左のみ簡約した式を返す' do
          expect(add.reduce({x: num1})).to eq(Add.new(Number.new(num1.value + num2.value), num2))
        end
      end

      context '式の左が簡約不可、右が簡約可能であれば' do
        let(:add) { Add.new(num3, Add.new(num1, num2)) }
        it '右のみ簡約した式を返す' do
          expect(add.reduce({})).to eq(Add.new(num3, Number.new(num1.value + num2.value)))
        end
      end
      context '式の右も左も簡約不可であれば' do
        let(:add) { Add.new(num3, num4) }
        it 'Numberのインスタンスを返す' do
          expect(add.reduce({})).to eq(Number.new(num3.value + num4.value))
        end
      end
    end
  end

  describe Multiply do
    let(:mul1) { Multiply.new(num1, num2) }
    it 'true' do
      expect(mul1.reducible?).to be_truthy
    end

    describe '#reduce' do
      context '式の左が簡約可能であれば' do
        let(:mul) { Multiply.new(Multiply.new(num1, num2), num2) }
        it '左のみ簡約した式を返す' do
          expect(mul.reduce({})).to eq(Multiply.new(Number.new(num1.value * num2.value), num2))
        end
      end

      context '式の左が簡約不可、右が簡約可能であれば' do
        let(:mul) { Multiply.new(num3, Multiply.new(num1, num2)) }
        it '右のみ簡約した式を返す' do
          expect(mul.reduce({})).to eq(Multiply.new(num3, Number.new(num1.value * num2.value)))
        end
      end
      context '式の右も左も簡約不可であれば' do
        let(:mul) { Multiply.new(num3, num4) }
        it 'Numberのインスタンスを返す' do
          expect(mul.reduce({})).to eq(Number.new(num3.value * num4.value))
        end
      end
    end
  end

  describe Machine do
    context '変数を使用しない場合' do
      let(:machine) do
        Machine.new(
          Assign.new(
            :x,
            Multiply.new(num3, num4)
          ),
          {x: num2}
        )
      end
      it do
        expect(machine.run).to match([DoNothing.new, {:x =>Number.new(12)}])
      end
    end

    context '変数を使用する場合' do
      it do
        machine = Machine.new(
          Assign.new(
            :x,
            Multiply.new(Variable.new(:x), Variable.new(:x))
          ),
          {x: Number.new(100)}
        )
        expect(machine.run).to eq([DoNothing.new, {:x => Number.new(10000)}])
      end
    end
    describe 'エラー確認' do
      it do
        m = Machine.new(
          Sequence.new(
            Assign.new(:x, Boolean.new(true)),
            Assign.new(:x, Add.new(Variable.new(:x), Number.new(1)))
          ),
          {}
        )
        expect{m.run}.to raise_error(NoMethodError)
      end
    end
  end

  describe LessThan do
    it do
      less_than = LessThan.new(num1, num2)
      expect(less_than.reduce({})).to eq(Boolean.new(true))
    end
  end

  describe If do
    let(:m) do
      Machine.new(
        If.new(
          Variable.new(:x),
          Assign.new(:y, Number.new(1)),
          Assign.new(:y, Number.new(2)),
        ),
        { x: Boolean.new(bool) }
      )
    end
    context 'conditionがtrueの場合' do
      let(:bool) { true }
      it do
        expect(m.run).to match([DoNothing.new, {x: Boolean.new(true), y: Number.new(1)}])
      end
    end
    context 'conditionがfalseの場合' do
      let(:bool) { false }
      it do
        expect(m.run).to match([DoNothing.new, {x: Boolean.new(false), y: Number.new(2)}])
      end
    end
  end

  describe Sequence do
    let(:m) do
      Machine.new(
        Sequence.new(
          Assign.new(:x, Add.new(num1, num2)),
          Assign.new(:y, Add.new(num3, num4))
        ),
        {}
      )
    end
    it do
      expect(m.run).to match([DoNothing.new, {x: Number.new(3), y: Number.new(7)}])
    end
  end

  describe While do
    let(:m) do
      Machine.new(
        While.new(
          LessThan.new(Variable.new(:x), Number.new(9)),
          Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
        ),
        {x: Number.new(1)}
      )
    end
    it do
      expect(m.run).to match([DoNothing.new, {:x => Number.new(9)}])
    end
  end
end
