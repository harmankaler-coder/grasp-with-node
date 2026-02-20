const User = require("../models/user");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

exports.register = async (req, res) => {
    try {
        const { name, email, password } = req.body;

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ msg: "User already exists!" });
        }
        const hashedPassword = await bcrypt.hash(password, 10);
        const user = new User({
            name,
            email,
            password: hashedPassword,
        });

        await user.save();
        res.json({ msg: "User registered successfully!" });

    } catch (error) {
        res.status(500).json({ msg: "Server error" });
    }
};

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({ msg: "User not found" });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ msg: "Invalid password" });
        }

        const accessToken = jwt.sign(
            { userId: user._id },
            "secret123",
            { expiresIn: "10m" }
        );

        const refreshToken = jwt.sign(
            { userId: user._id },
            "refresh_secret123",
            { expiresIn: "7d" },
        );

        user.refreshToken = refreshToken;
        await user.save();

        res.json({
            accessToken,
            refreshToken,
            userId: user._id,
            name: user.name,
            email: user.email,
        });

    } catch (error) {
        res.status(500).json({ msg: "Server error" });
    }
};

exports.refreshToken = async (req, res) => {
    try {
        const { refreshToken } = req.body;

        if (!refreshToken) {
            return res.status(401).json({ msg: "No Refresh Token Provided" });
        }
        const user = await User.findOne({ refreshToken });

        if (!user) {
            return res.status(401).json({ msg: "Invalid Refresh Token" });
        }

        jwt.verify(refreshToken, "refresh_secret123", (err, decoded) => {
            if (err) {
                return res.status(401).json({ msg: "Invalid Refresh Token" });
            }

            const newAccesstoken = jwt.sign(
                { userId: user._id },
                "secret123",
                { expiresIn: "10m" }
            );

            res.json({
                accessToken: newAccesstoken
            });
        });
    } catch (error) {
        res.status(500).json({ msg: "Server error" });
    }
};