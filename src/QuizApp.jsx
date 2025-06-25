// QuizApp.jsx
import React, { useState, useEffect } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import * as XLSX from "xlsx";
import * as docx from "docx-preview";

function shuffleArray(array) {
  const copy = [...array];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

function detectChoices(text) {
  const choices = [];
  const lines = text.split(/\n|\r/);
  const stem = [];
  for (let line of lines) {
    if (/^[A-D]\./.test(line.trim())) {
      choices.push(line.trim());
    } else {
      stem.push(line.trim());
    }
  }
  return { question: stem.join(' '), choices };
}

export default function QuizApp() {
  const [questions, setQuestions] = useState([]);
  const [answers, setAnswers] = useState([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [answer, setAnswer] = useState("");
  const [wrongSet, setWrongSet] = useState([]);
  const [mode, setMode] = useState("sequential"); // sequential | random | review

  useEffect(() => {
    const storedWrong = localStorage.getItem("wrongQuestions");
    if (storedWrong) {
      setWrongSet(JSON.parse(storedWrong));
    }
  }, []);

  const parseExcel = (file, type) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      const data = new Uint8Array(e.target.result);
      const workbook = XLSX.read(data, { type: "array" });
      const sheetName = workbook.SheetNames[0];
      const worksheet = workbook.Sheets[sheetName];
      const json = XLSX.utils.sheet_to_json(worksheet);

      if (type === "questions") {
        const parsed = json.map((row) => {
          const raw = row["题目"] || row["Question"] || "";
          const { question, choices } = detectChoices(raw);
          return { question, choices };
        });
        setQuestions(parsed);
      } else if (type === "answers") {
        const parsedAnswers = json.map((row) => row["答案"] || row["Answer"]).filter(a => !!a);
        setAnswers(parsedAnswers);
      }
    };
    reader.readAsArrayBuffer(file);
  };

  const parseWord = (file, type) => {
    const reader = new FileReader();
    reader.onload = async (e) => {
      const arrayBuffer = e.target.result;
      const container = document.createElement("div");
      await docx.renderAsync(arrayBuffer, container);
      const text = container.innerText.split("\n\n").filter(Boolean);

      if (type === "questions") {
        const parsed = text.map(raw => detectChoices(raw));
        setQuestions(parsed);
      } else if (type === "answers") {
        setAnswers(text.map(line => line.trim()).filter(Boolean));
      }
    };
    reader.readAsArrayBuffer(file);
  };

  const handleFile = (e, type) => {
    const file = e.target.files[0];
    if (!file) return;
    if (file.name.endsWith(".docx")) {
      parseWord(file, type);
    } else {
      parseExcel(file, type);
    }
  };

  const mergeQA = () => {
    if (questions.length === answers.length) {
      const merged = questions.map((q, i) => ({ ...q, answer: answers[i] }));
      const finalList = mode === "random" ? shuffleArray(merged) : merged;
      setQuestions(finalList);
      setCurrentIndex(0);
    } else {
      alert("题目与答案数量不一致，请检查上传文件");
    }
  };

  const handleAnswer = (ans) => {
    const current = questions[currentIndex];
    const userAnswer = ans !== undefined ? ans : answer;
    const correct = current.answer.trim().toLowerCase() === userAnswer.trim().toLowerCase();
    if (!correct) {
      const updatedWrong = [...wrongSet, current];
      setWrongSet(updatedWrong);
      localStorage.setItem("wrongQuestions", JSON.stringify(updatedWrong));
    }
    setAnswer("");
    setCurrentIndex((prev) => prev + 1);
  };

  const startReview = () => {
    const reviewList = shuffleArray(wrongSet);
    setQuestions(reviewList);
    setCurrentIndex(0);
    setMode("review");
  };

  const resetApp = () => {
    setQuestions([]);
    setAnswers([]);
    setCurrentIndex(0);
    setAnswer("");
    setWrongSet([]);
    setMode("sequential");
    localStorage.removeItem("wrongQuestions");
  };

  const fileUpload = (
    <div className="flex flex-col gap-2">
      <div className="flex gap-2 items-center">
        <Input type="file" accept=".xlsx,.xls,.docx" onChange={(e) => handleFile(e, "questions")} />
        <span>上传题目文件（Excel 或 Word）</span>
      </div>
      <div className="flex gap-2 items-center">
        <Input type="file" accept=".xlsx,.xls,.docx" onChange={(e) => handleFile(e, "answers")} />
        <span>上传答案文件（Excel 或 Word）</span>
      </div>
      <div className="flex gap-2">
        <Button onClick={() => { setMode("sequential"); mergeQA(); }}>顺序刷题</Button>
        <Button onClick={() => { setMode("random"); mergeQA(); }}>随机刷题</Button>
      </div>
    </div>
  );

  if (questions.length === 0 || !questions[0].answer) return (
    <div className="p-4">
      <h1 className="text-xl font-bold mb-2">上传题库和答案文件</h1>
      {fileUpload}
    </div>
  );

  if (currentIndex >= questions.length) {
    return (
      <div className="p-4">
        <h1 className="text-xl font-bold">题目完成</h1>
        <p className="mb-2">答错题数：{wrongSet.length}</p>
        {wrongSet.length > 0 && mode !== "review" && (
          <Button onClick={startReview}>重做错题（随机）</Button>
        )}
        <Button variant="secondary" onClick={resetApp}>重新开始</Button>
      </div>
    );
  }

  const current = questions[currentIndex];

  return (
    <div className="p-4">
      <Card>
        <CardContent className="space-y-4">
          <h2 className="text-lg font-semibold">题目 {currentIndex + 1} / {questions.length}</h2>
          <p>{current.question}</p>
          {current.choices?.length ? (
            <div className="space-y-2">
              {current.choices.map((opt, idx) => (
                <Button key={idx} variant="outline" onClick={() => handleAnswer(opt.split(".")[0])}>
                  {opt}
                </Button>
              ))}
            </div>
          ) : (
            <>
              <Input
                value={answer}
                onChange={(e) => setAnswer(e.target.value)}
                placeholder="请输入答案"
              />
              <Button onClick={() => handleAnswer()}>提交</Button>
            </>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
