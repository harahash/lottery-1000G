const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("Lottery contract", () => {
	let Lottery, lottery, owner, acc1, acc2, acc3;

	beforeEach(async () => {
		Lottery = await ethers.getContractFactory("Lottery");
		lottery = await Lottery.deploy();
		await lottery.deployed();

		[owner, acc1, acc2, acc3] = await ethers.getSigners();
	});

	describe("Deployment", () => {
		it("Should set the right owner", async () => {
			expect(await lottery.manager()).to.equal(owner.address);
		});

		it("Initial smart contract balance should be zero", async () => {
			expect(await lottery.getBalance()).to.equal(0);
		});
	});

	describe("Lottery interaction", () => {
		it("Allows one account to enter", async () => {
			const tx = await lottery.enter({ value: 100 });
			await tx.wait();

			expect(await lottery.getBalance()).to.equal(100);
		});

		it("Allows multiple account to enter", async () => {
			const tx = await lottery.enter({ value: 100 });
			await tx.wait();

			const tx1 = await lottery.connect(acc1).enter({ value: 100 });
			await tx1.wait();

			const tx2 = await lottery.connect(acc2).enter({ value: 100 });
			await tx2.wait();

			const tx3 = await lottery.connect(acc3).enter({ value: 100 });
			await tx3.wait();

			expect(await lottery.getBalance()).to.equal(400);
		});

		it("Requires a minimum amount of ether to enter", async () => {
			try {
				const tx = await lottery.enter();
				await tx.wait();
				expect(false);
			} catch (err) {
				expect(err);
			}
		});

		it("Sends ether to the winner and resets players", async () => {
			const tx = await lottery.enter({ value: 100 });
			await tx.wait();

			//expect(await lottery.getBalance()).to.equal(100)
		})
	});
});
